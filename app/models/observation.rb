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
#  details               :text
#  concern_opinion       :text
#  litigation_status     :string
#

class Observation < ApplicationRecord
  # include Translatable
  include Activable
  include ValidationHelper

  # translates :details, :concern_opinion, :litigation_status, touch: true
  # active_admin_translates :details, :concern_opinion, :litigation_status

  enum observation_type: { "operator" => 0, "government" => 1 }
  enum validation_status: { "Created" => 0, "Ready for revision" => 1, "Under revision" => 2, "Approved" => 3, "Rejected" => 4 }
  enum evidence_type: { "Government Documents" => 0, "Company Documents" => 1, "Photos" => 2, "Testimony from local communities" => 3, "Other" => 4, "Evidence presented in the report" => 5, "Maps" => 6 }
  enum location_accuracy: { "Estimated location" => 0, "GPS coordinates extracted from photo" => 1, "Accurate GPS coordinates" => 2 }


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
  has_many :observation_documents

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

  validates :country_id,       presence: true
  validates :publication_date, presence: true
  validates :validation_status, presence: true
  validates :observation_type, presence: true

  before_save    :set_active_status
  before_save    :check_is_physical_place
  before_save    :set_centroid
  after_create   :update_operator_scores
  before_destroy :destroy_documents
  after_destroy  :update_operator_scores
  after_save     :update_operator_scores,   if: 'publication_date_changed? || severity_id_changed? || is_active_changed?'
  after_save     :update_reports_observers, if: 'observation_report_id_changed?'
  after_save     :remove_documents
  after_save     :update_fmu_geojson
  after_destroy  :update_fmu_geojson

  after_save       :prepare_notify_observer
  after_commit     :notify_observer


  # TODO Check if we can change the joins with a with_translations(I18n.locale)
  scope :active, -> { joins(:translations).where(is_active: true) }
  scope :own_with_inactive, ->(observer) {
    joins('INNER JOIN "observer_observations" ON "observer_observations"."observation_id" = "observations"."id"
INNER JOIN "observers" as "all_observers" ON "observer_observations"."observer_id" = "all_observers"."id"')
        .where("all_observers.id = #{observer}")
  }

  scope :by_category,       ->(category_id) { joins(:subcategory).where(subcategories: { category_id: category_id }) }
  scope :by_severity_level, ->(level) { joins(:subcategory).joins("inner join severities sevs on subcategories.id = sevs.subcategory_id and observations.severity_id = sevs.id").where(sevs: { level: level }) }
  scope :by_government,     ->(government_id) { joins(:governments).where(governments: { id: government_id }) }
  scope :pending,           -> { joins(:translations).where(validation_status: ['Created', 'Under revision']) }
  scope :created,           -> { joins(:translations).where(validation_status: ['Created', 'Ready for revision']) }
  scope :hidden,            -> { where(hidden: true) }
  scope :visible,           -> { where(hidden: [false, nil]) }
  scope :order_by_category, ->(order = 'ASC') { joins("inner join subcategories s on observations.subcategory_id = s.id inner join categories c on s.category_id = c.id inner join category_translations ct on ct.category_id = c.id and ct.locale = '#{I18n.locale}'").order("ct.name #{order}") }

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
    operator&.calculate_observations_scores
  end

  def set_active_status
    self.is_active = (self.validation_status == 'Approved' && self.hidden != true)
    nil
  end

  def destroy_documents
    mark_for_destruction # Hack to work with the hard delete of operator documents
    ActiveRecord::Base.connection.execute("DELETE FROM observation_documents WHERE observation_id = #{id}")
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

  def prepare_notify_observer
    @notify_observer = true if validation_status_changed?
  end

  def notify_observer
    return unless @notify_observer

    observers.each do |observer|
      MailService.notify_observer_status_changed(observer, self)
    end
  end
end
