# frozen_string_literal: true

# == Schema Information
#
# Table name: observations
#
#  id                    :integer          not null, primary key
#  severity_id           :integer
#  observation_type      :integer          not null
#  user_id               :integer
#  publication_date      :datetime
#  country_id            :integer
#  operator_id           :integer
#  pv                    :string
#  is_active             :boolean          default("true")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  lat                   :decimal(, )
#  lng                   :decimal(, )
#  fmu_id                :integer
#  subcategory_id        :integer
#  validation_status     :integer          default("0"), not null
#  observation_report_id :integer
#  actions_taken         :text
#  modified_user_id      :integer
#  law_id                :integer
#  location_information  :string
#  is_physical_place     :boolean          default("true")
#  evidence_type         :integer
#  location_accuracy     :integer
#  evidence_on_report    :string
#  hidden                :boolean          default("false")
#  admin_comment         :text
#  monitor_comment       :text
#  responsible_admin_id  :integer
#  deleted_at            :datetime
#  details               :text
#  concern_opinion       :text
#  litigation_status     :string
#  deleted_at            :datetime
#

class Observation < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  include Translatable
  include Activable
  include ValidationHelper

  translates :details, :concern_opinion, :litigation_status, touch: true, versioning: :paper_trail, paranoia: true
  active_admin_translates :details, :concern_opinion, :litigation_status

  enum observation_type: { "operator" => 0, "government" => 1 }
  enum validation_status: { "Created" => 0, "Ready for QC" => 1, "QC in progress" => 2, "Approved" => 3,
                            "Rejected" => 4, "Needs revision" => 5, "Ready for publication" => 6,
                            "Published (no comments)" => 7, "Published (not modified)" => 8,
                            "Published (modified)" => 9 }
  enum evidence_type: { "Government Documents" => 0, "Company Documents" => 1, "Photos" => 2,
                        "Testimony from local communities" => 3, "Other" => 4, "Evidence presented in the report" => 5,
                        "Maps" => 6 }
  enum location_accuracy: { "Estimated location" => 0, "GPS coordinates extracted from photo" => 1,
                            "Accurate GPS coordinates" => 2 }

  STATUS_TRANSITIONS={
      monitor: {
          nil => ['Created', 'Ready for QC'],
          'Created' => ['Ready for QC'],
          'Needs revision' => ['Ready for QC', 'Published (not modified)', 'Published (modified)'],
          'Ready for publication' => ['Published (no comments)'],
          'Published (modified)' => ['Ready for QC'],
          'Published (not modified)' => ['Ready for QC'],
          'Published (no comments)' => ['Ready for QC']
      },
      admin: {
          'Ready for QC' => ['QC in progress'],
          'QC in progress' => ['Needs revision', 'Ready for publication']
      }
  }.freeze

  attr_accessor :user_type

  belongs_to :country,        inverse_of: :observations
  belongs_to :severity,       inverse_of: :observations
  belongs_to :operator,       inverse_of: :observations, optional: true
  belongs_to :user,           inverse_of: :observations, optional: true
  belongs_to :modified_user,  class_name: 'User', foreign_key: 'modified_user_id', optional: true
  belongs_to :fmu,            inverse_of: :observations, optional: true
  belongs_to :law,            inverse_of: :observations, optional: true
  belongs_to :observation_report

  belongs_to :subcategory, inverse_of: :observations, optional: true

  has_many :species_observations, dependent: :destroy
  has_many :species, through: :species_observations

  has_many :governments_observations, dependent: :destroy
  has_many :governments, through: :governments_observations

  has_many :observer_observations, dependent: :destroy
  has_many :observers, through: :observer_observations

  has_many :observation_operators, dependent: :destroy
  has_many :relevant_operators, through: :observation_operators, source: :operator

  has_many :comments,  as: :commentable, dependent: :destroy
  has_many :photos,    as: :attacheable, dependent: :destroy
  has_many :observation_documents, dependent: :destroy

  belongs_to :responsible_admin,  class_name: 'User', foreign_key: 'responsible_admin_id', optional: true

  accepts_nested_attributes_for :photos,                       allow_destroy: true
  accepts_nested_attributes_for :observation_documents,        allow_destroy: true
  accepts_nested_attributes_for :observation_report,           allow_destroy: true
  accepts_nested_attributes_for :subcategory,                  allow_destroy: false

  with_options if: :operator? do
    validate :validate_governments_absences
  end

  with_options if: :government? do
    validates :operator_id, absence: true
    validate :active_government
  end

  validate :evidence_presented_in_the_report
  validate :status_changes, if: -> { user_type.present? }

  validates :country_id,       presence: true
  validates :publication_date, presence: true
  validates :validation_status, presence: true
  validates :observation_type, presence: true

  before_create  :set_responsible_admin
  before_save    :set_active_status
  before_save    :check_is_physical_place
  before_save    :set_centroid
  after_destroy  :update_operator_scores
  after_save     :update_operator_scores,   if: 'publication_date_changed? || severity_id_changed? || is_active_changed?'
  after_save     :update_reports_observers, if: 'observation_report_id_changed?'
  after_save     :remove_documents
  after_save     :update_fmu_geojson
  after_destroy  :update_fmu_geojson

  after_save       :prepare_notifications
  after_commit     :notify


  # TODO Check if we can change the joins with a with_translations(I18n.locale)
  scope :active, -> { includes(:translations).where(is_active: true).visible }
  scope :own_with_inactive, ->(observer) {
    joins('INNER JOIN "observer_observations" ON "observer_observations"."observation_id" = "observations"."id"
INNER JOIN "observers" as "all_observers" ON "observer_observations"."observer_id" = "all_observers"."id"')
        .where("all_observers.id = #{observer}")
  }

  scope :by_category,       ->(category_id) { joins(:subcategory).where(subcategories: { category_id: category_id }) }
  scope :by_severity_level, ->(level) { joins(:subcategory).joins("inner join severities sevs on subcategories.id = sevs.subcategory_id and observations.severity_id = sevs.id").where(sevs: { level: level }) }
  scope :by_government,     ->(government_id) { joins(:governments).where(governments: { id: government_id }) }
  scope :pending,           -> { joins(:translations).where(validation_status: ['Created', 'QC in progress']) }
  scope :created,           -> { joins(:translations).where(validation_status: ['Created', 'Ready for QC']) }
  scope :hidden,            -> { where(hidden: true) }
  scope :visible,           -> { where(hidden: [false, nil]) }
  scope :order_by_category, ->(order = 'ASC') { joins("inner join subcategories s on observations.subcategory_id = s.id inner join categories c on s.category_id = c.id inner join category_translations ct on ct.category_id = c.id and ct.locale = '#{I18n.locale}'").order("ct.name #{order}") }
  scope :bigger_date,       ->(date) { where('observations.created_at <= ?', date + 1.day) }

  class << self
    def translated_types
      observation_types.map { |t| [I18n.t("observation_types.#{t.first}", default: t.first), t.first.camelize] }
    end
  end

  def user_name
    self.try(:user).try(:name)
  end

  def translated_type
    I18n.t("observation_types.#{observation_type}")
  end

  def cache_key
    super + '-' + Globalize.locale.to_s
  end

  def update_reports_observers
    return if observation_report.blank?

    observation_report.observer_ids =
      observation_report.observations.map(&:observers).map(&:ids).flatten
  end


  private

  def check_is_physical_place
    return if is_physical_place

    self.lat = nil
    self.lng = nil
    self.fmu = nil
  end

  def set_centroid
    return if fmu.blank? || lat.present? || lng.present?

    self.lat = fmu.geojson.dig('properties', 'centroid', 'coordinates').first rescue nil
    self.lng = fmu.geojson.dig('properties', 'centroid', 'coordinates').second rescue nil
  end

  def update_operator_scores
    ScoreOperatorObservation.recalculate! operator if operator.present?
  end

  def set_active_status
    self.is_active = (
      ["Published (no comments)", "Published (not modified)", "Published (modified)"].include?(validation_status) &&
          self.hidden != true
    )
    nil
  end

  # Sets the responsible admin for an observation
  # It starts by checking the monitor organization of the uploader to find its responsible person
  # And if it doesn't find any, it iterates through all the monitors
  def set_responsible_admin
    self.responsible_admin = user&.observer&.responsible_user&.id
    return if self.responsible_admin

    observers.each do |observer|
      if observer.responsible_user.present?
        self.responsible_admin = observer.responsible_user&.id
      end
    end
  end

  def active_government
    return if persisted? ||
              governments.none? ||
              governments.select{ |g| g.is_active? }.any?(&:is_active)

    errors.add(:governments, "At least one government should be active")
  end

  def validate_governments_absences
    return if governments.none?

    errors.add(:governments, "Should have no governments with 'operator' type")
  end

  def status_changes
    return unless @user_type
    return if validation_status == validation_status_was
    return if STATUS_TRANSITIONS.dig(@user_type, validation_status_was)&.include? validation_status

    errors.add(:validation_status,
               "Invalid validation change for #{@user_type}. Can't move from '#{validation_status_was}' to '#{validation_status}'")
  end

  def evidence_presented_in_the_report
    if evidence_type == 'Evidence presented in the report' && evidence_on_report.blank?
      errors.add(:evidence_on_report, 'You must add information on where to find the evidence on the report')
    end
    if evidence_type != 'Evidence presented in the report' && evidence_on_report.present?
      errors.add(:evidence_on_report, 'This field can only be present when the evidence is presented on the report')
    end
  end

  # Soft removes all the evidence if the evidence type is "Observation in the report"
  def remove_documents
    return if evidence_type != 'Evidence presented in the report'

    ObservationDocument.where(observation_id: id).destroy_all
  end

  # If the observation is for an fmu, it updates its geojson with the new count
  def update_fmu_geojson
    return unless fmu_id

    fmu.update_geojson
    fmu.save
  end

  def prepare_notifications
    @notify = true if validation_status_changed?
  end

  def notify
    return unless @notify

    notify_responsible
    notify_observers
    notify_qc
  end

  def notify_observers
    observers.each do |observer|
      MailService.notify_observers_status_changed(observer, self)
    end
  end

  def notify_responsible
    return unless validation_status == 'Ready for QC'

    MailService.new.notify_responsible(self).deliver
  end

  def notify_qc
    return unless ["Published (not modified)", "Published (modified)"].include? validation_status
    return unless responsible_admin&.email

    MailService.new.notify_admin_published(self).deliver
  end
end
