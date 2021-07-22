# frozen_string_literal: true

# == Schema Information
#
# Table name: operators
#
#  id                :integer          not null, primary key
#  operator_type     :string
#  country_id        :integer
#  concession        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_active         :boolean          default("true")
#  logo              :string
#  operator_id       :string
#  fa_id             :string
#  address           :string
#  website           :string
#  approved          :boolean          default("true"), not null
#  email             :string
#  holding_id        :integer
#  country_doc_rank  :integer
#  country_operators :integer
#  name              :string
#  details           :text
#

class Operator < ApplicationRecord
  has_paper_trail
  include Translatable
  translates :name, :details, touch: true, versioning: :paper_trail
  active_admin_translates :name, :details do
    validates_presence_of :name
  end

  mount_base64_uploader :logo, LogoUploader
  attr_accessor :delete_logo

  TYPES = ['Logging company', 'Artisanal', 'Community forest', 'Estate', 'Industrial agriculture', 'Mining company',
           'Sawmill', 'Other', 'Unknown'].freeze

  belongs_to :country, inverse_of: :operators, optional: true
  belongs_to :holding, inverse_of: :operators, optional: true
  has_many :all_operator_documents, class_name: 'OperatorDocument'

  has_many :observations, -> { active.uniq },  inverse_of: :operator, dependent: :nullify
  has_many :all_observations, class_name: 'Observation', inverse_of: :operator, dependent: :nullify
  has_many :users, inverse_of: :operator, dependent: :destroy

  has_many :fmu_operators, -> { where(current: true) }, inverse_of: :operator, dependent: :destroy
  has_many :fmus, through: :fmu_operators
  has_many :all_fmu_operators, class_name: 'FmuOperator', inverse_of: :operator, dependent: :destroy
  has_many :all_fmus, through: :all_fmu_operators, source: :fmu

  has_many :operator_documents
  has_many :operator_document_countries
  has_many :operator_document_fmus

  has_many :operator_document_histories
  has_many :operator_document_country_histories
  has_many :operator_document_fmu_histories

  has_many :score_operator_documents
  has_one :score_operator_document, ->{ current }, class_name: 'ScoreOperatorDocument', inverse_of: :operator
  has_many :score_operator_observations
  has_one :score_operator_observation, -> { current }, class_name: 'ScoreOperatorObservation', inverse_of: :operator

  has_many :sawmills

  accepts_nested_attributes_for :fmu_operators, :all_fmu_operators

  before_validation { self.remove_logo! if self.delete_logo == '1' }
  after_create :create_operator_id
  after_create :create_documents
  after_update :recalculate_scores, if: :approved_changed?
  after_update :create_documents, if: :fa_id_changed?
  after_update :refresh_ranking, if: -> { fa_id_changed? || is_active_changed? }
  before_destroy :really_destroy_documents

  validates :name, presence: true
  validates :website, url: true, if: lambda { |x| x.website.present? }
  validates :operator_type, inclusion: { in: TYPES }
  validates :country, presence: true, on: :create

  scope :by_name_asc, -> {
    includes(:translations).with_translations(I18n.available_locales)
                           .order('operator_translations.name ASC')
  }

  scope :active,   -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :fa_operator, -> { where("fa_id <> ''") }

  default_scope { includes(:translations) }

  scope :filter_by_country_ids,   ->(country_ids)     { where(country_id: country_ids.split(',')) }
  # TODO Refactor this when merging the branches
  scope :fmus_with_certification_fsc,     ->          { joins(:fmus).where(fmus: { certification_fsc: true }).distinct }
  scope :fmus_with_certification_pefc,    ->          { joins(:fmus).where(fmus: { certification_pefc: true }).distinct }
  scope :fmus_with_certification_olb,     ->          { joins(:fmus).where(fmus: { certification_olb: true }).distinct }
  scope :fmus_with_certification_pafc,    ->          { joins(:fmus).where(fmus: { certification_pafc: true }).distinct }
  scope :fmus_with_certification_fsc_cw,  ->          { joins(:fmus).where(fmus: { certification_fsc_cw: true }).distinct }
  scope :fmus_with_certification_tlv,     ->          { joins(:fmus).where(fmus: { certification_tlv: true }).distinct }
  scope :fmus_with_certification_ls,      ->          { joins(:fmus).where(fmus: { certification_ls: true }).distinct }


  class Translation
    after_save do
      if name_changed? && locale == :en
        Operator.find_by(id: operator_id)&.fmus&.find_each { |fmu| fmu.save }
      end
    end
  end

  class << self
    def fetch_all(options)
      country_ids = options['country_ids']    if options.present? && options['country_ids'].present?

      operators = includes(:country, :users)
      operators = operators.filter_by_country_ids(country_ids)    if country_ids.present?
      operators
    end

    def operator_select
      by_name_asc.map { |c| [c.name, c.id] }
    end

    def types
      TYPES
    end

    def translated_types
      types.map { |t| [I18n.t("operator_types.#{t}", default: t), t.camelize] }
    end
  end

  def cache_key
    super + '-' + Globalize.locale.to_s
  end

  def rebuild_documents
    return if fa_id.blank?

    country = RequiredOperatorDocument.where(country_id: country_id).any? ? country_id : nil

    # Country Documents
    RequiredOperatorDocumentCountry.where(country_id: country).find_each do |rodc|
      if OperatorDocumentCountry.where(required_operator_document_id: rodc.id, operator_id: id).blank?
        OperatorDocumentCountry.where(required_operator_document_id: rodc.id, operator_id: id,
                                      status: OperatorDocument.statuses[:doc_not_provided]).create!
      end
    end

    # FMU Documents
    RequiredOperatorDocumentFmu.where(country_id: country).find_each do |rodf|
      Fmu.joins(:fmu_operators).where(fmu_operators: { operator_id: id, current: true }).find_each do |fmu|
        unless OperatorDocumentFmu.where(required_operator_document_id: rodf.id, operator_id: id, fmu_id: fmu.id).any?
          OperatorDocumentFmu.where(required_operator_document_id: rodf.id, operator_id: id, fmu_id: fmu.id,
                                    status: OperatorDocument.statuses[:doc_not_provided]).create!
        end
      end
    end
  end

  def self.active_with_fmus_array
    name_column = Arel.sql('operator_translations.name')
    Operator.active.with_translations.includes(:fmus).group(:id, name_column).order(name_column)
        .pluck(:id, name_column, 'array_agg(fmus.id) fmu_ids')
  end

  private

  def recalculate_scores
    ScoreOperatorDocument.recalculate!(self)
  end

  def refresh_ranking
    RankingOperatorDocument.refresh_for_country(country)
  end

  # rubocop:disable Rails/SkipsModelValidations
  def create_operator_id
    if country_id.present?
      update_columns(operator_id: "#{country.iso}-unknown-#{id}")
    else
      update_columns(operator_id: "na-unknown-#{id}")
    end
  end
  # rubocop:enable Rails/SkipsModelValidations

  def create_documents
    return if fa_id.blank? || country_id.blank?

    country = RequiredOperatorDocument.where(country_id: country_id).any? ? country_id : nil

    if operator_document_countries.none?
      RequiredOperatorDocumentCountry.where(country_id: country).find_each do |rodc|
        OperatorDocumentCountry.where(required_operator_document_id: rodc.id, operator_id: id).first_or_create do |odc|
          odc.update!(status: OperatorDocument.statuses[:doc_not_provided])
        end
      end
    end

    if operator_document_fmus.none?
      RequiredOperatorDocumentFmu.where(country_id: country).find_each do |rodf|
        self.fmus.find_each do |fmu|
          OperatorDocumentFmu.where(required_operator_document_id: rodf.id, operator_id: id, fmu_id: fmu.id).first_or_create do |odf|
            odf.update!(status: OperatorDocument.statuses[:doc_not_provided])
          end
        end
      end
    end
  end

  def really_destroy_documents
    mark_for_destruction # Hack to work with the hard delete of operator documents
    ActiveRecord::Base.connection.execute("DELETE FROM operator_documents WHERE operator_id = #{id}")
  end
end
