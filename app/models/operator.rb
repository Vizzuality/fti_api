# frozen_string_literal: true

# == Schema Information
#
# Table name: operators
#
#  id                                 :integer          not null, primary key
#  operator_type                      :string
#  country_id                         :integer
#  concession                         :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  is_active                          :boolean          default("true")
#  logo                               :string
#  operator_id                        :string
#  percentage_valid_documents_all     :float
#  percentage_valid_documents_country :float
#  percentage_valid_documents_fmu     :float
#  score_absolute                     :float
#  score                              :integer
#  obs_per_visit                      :float
#  fa_id                              :string
#  address                            :string
#  website                            :string
#  country_doc_rank                   :integer
#  country_operators                  :integer
#  approved                           :boolean          default("true"), not null
#  name                               :string
#  details                            :text
#

class Operator < ApplicationRecord
  # include Translatable
  # translates :name, :details, touch: true
  # active_admin_translates :name, :details

  mount_base64_uploader :logo, LogoUploader
  attr_accessor :delete_logo

  TYPES = ['Logging company', 'Artisanal', 'Community forest', 'Estate', 'Industrial agriculture', 'Mining company',
           'Sawmill', 'Other', 'Unknown'].freeze

  belongs_to :country, inverse_of: :operators, optional: true
  has_many :all_operator_documents, class_name: 'OperatorDocument'

  has_many :observations, -> { active },  inverse_of: :operator, dependent: :destroy
  has_many :all_observations, class_name: 'Observation', inverse_of: :operator, dependent: :destroy
  has_many :users, inverse_of: :operator, dependent: :destroy

  has_many :fmu_operators, -> { where(current: true) }, inverse_of: :operator, dependent: :destroy
  has_many :fmus, through: :fmu_operators
  has_many :all_fmu_operators, class_name: 'FmuOperator', inverse_of: :operator, dependent: :destroy
  has_many :all_fmus, through: :all_fmu_operators, source: :fmu

  accepts_nested_attributes_for :fmu_operators, :all_fmu_operators

  has_many :operator_documents, -> { actual }
  has_many :operator_document_countries, -> { actual }
  has_many :operator_document_fmus, -> { actual }

  has_many :sawmills

  before_validation { self.remove_logo! if self.delete_logo == '1' }
  after_create :create_operator_id
  after_create :create_documents
  after_update :create_documents, if: :fa_id_changed?
  before_destroy :really_destroy_documents

  validates :name, presence: true
  validates :website, url: true, if: lambda { |x| x.website.present? }
  validates :operator_type, inclusion: { in: TYPES }

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


  # class Translation
  #   after_save do
  #     if name_changed?
  #       Operator.find_by(id: operator_id)&.fmus&.find_each { |fmu| fmu.save }
  #     end
  #   end
  # end

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

  def update_valid_documents_percentages
    if fa_id.present?
      # For the total number of documents, we take into account only the documents which
      # are required (current and not deleted) and whose required_operator_document
      # is also not deleted

      if approved
        percentage_approved
      else
        percentage_non_approved
      end

      self.percentage_valid_documents_all = 0 if self.percentage_valid_documents_all.nan?
      self.percentage_valid_documents_country = 0 if self.percentage_valid_documents_country.nan?
      self.percentage_valid_documents_fmu = 0 if self.percentage_valid_documents_fmu.nan?

      self.save!
    end
  end

  # Calculates the percentage of documents for when the operator hasn't been approved
  # This counts only public documents
  def percentage_non_approved
    self.percentage_valid_documents_all =
      operator_documents.valid.available.ns.count.
          / operator_documents.required.ns.count.to_f rescue 0
    self.percentage_valid_documents_fmu =
      operator_document_fmus.valid.available.ns.count.to_f / operator_document_fmus.required.ns.count.to_f rescue 0
    self.percentage_valid_documents_country =
      operator_document_countries.valid.available.ns.count.to_f / operator_document_countries.required.ns.count.to_f rescue 0
  end

  # Calculates the percentage documents knowing they've all been approved
  def percentage_approved
    self.percentage_valid_documents_all =
      operator_documents.valid.ns.count.to_f / operator_documents.required.ns.count.to_f rescue 0
    self.percentage_valid_documents_fmu =
      operator_document_fmus.valid.ns.count.to_f / operator_document_fmus.ns.required.count.to_f rescue 0
    self.percentage_valid_documents_country =
      operator_document_countries.valid.ns.count.to_f / operator_document_countries.required.ns.count.to_f rescue 0
  end

  def calculate_observations_scores
    return if fa_id.blank?

    observations_query = observations.unscope(:joins)
    number_of_visits = observations_query.select('date(publication_date)')
                                         .group('date(publication_date)').count
    number_of_visits = number_of_visits.keys.count

    # When there are no observations
    if number_of_visits.zero?
      self.obs_per_visit = nil
      self.score_absolute = nil
      save!
      return
    end

    self.obs_per_visit = observations_query.count.to_f / number_of_visits rescue nil

    high = observations_query.joins(:severity).where('severities.level = 3').count.to_f / number_of_visits
    medium = observations_query.joins(:severity).where('severities.level = 2').count.to_f / number_of_visits
    low = observations_query.joins(:severity).where('severities.level = 1').count.to_f / number_of_visits
    unknown = observations_query.joins(:severity).where('severities.level = 0').count.to_f / number_of_visits
    self.score_absolute = (4 * high + 2 * medium + 2 * unknown + low).to_f / 9

    save!
  end

  class << self
    # Calculates the ranking of each operator within its own country
    # based on the percentage of documents uploaded
    def calculate_document_ranking
      Country.active.find_each do |country|
        number_of_operators = country.fa_operators.count
        rank_position = 0
        country.fa_operators.order(percentage_valid_documents_all: :desc).each do |o|
          if o.percentage_valid_documents_all.present?
            rank = rank_position + 1
            rank_position += 1
          else
            rank = number_of_operators
          end
          o.update(country_operators: number_of_operators,
                   country_doc_rank: rank)
        end
      end
    end

    # rubocop:disable Rails/SkipsModelValidations
    def calculate_scores
      Operator.active.fa_operator.where(score_absolute: nil).update_all(score: 0)

      number_operators = Operator.active.fa_operator.where.not(score_absolute: nil).count
      third_operators = (number_operators / 3).to_i
      Operator.active.fa_operator.where.not(score_absolute: nil).order(:score_absolute)
        .limit(third_operators).update_all(score: 1)
      Operator.active.fa_operator.where.not(score_absolute: nil)
        .order("score_absolute LIMIT #{third_operators} OFFSET #{third_operators}").update_all(score: 2)
      Operator.active.fa_operator.where.not(score_absolute: nil)
        .order("score_absolute OFFSET #{2 * third_operators}").update_all(score: 3)
    end
    # rubocop:enable Rails/SkipsModelValidations
  end


  def rebuild_documents
    return if fa_id.blank?

    country = RequiredOperatorDocument.where(country_id: country_id).any? ? country_id : nil

    # Country Documents
    RequiredOperatorDocumentCountry.where(country_id: country).find_each do |rodc|
      if OperatorDocumentCountry.where(required_operator_document_id: rodc.id, operator_id: id).blank?
        OperatorDocumentCountry.where(required_operator_document_id: rodc.id, operator_id: id,
                                      status: OperatorDocument.statuses[:doc_not_provided],
                                      current: true).create!
      end
    end

    # FMU Documents
    RequiredOperatorDocumentFmu.where(country_id: country).find_each do |rodf|
      Fmu.joins(:fmu_operators).where(fmu_operators: { operator_id: id, current: true }).find_each do |fmu|
        unless OperatorDocumentFmu.where(required_operator_document_id: rodf.id, operator_id: id, fmu_id: fmu.id).any?
          OperatorDocumentFmu.where(required_operator_document_id: rodf.id, operator_id: id, fmu_id: fmu.id,
                                    status: OperatorDocument.statuses[:doc_not_provided],
                                    current: true).create!
        end
      end
    end
  end

  private

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
          odc.update!(status: OperatorDocument.statuses[:doc_not_provided], current: true)
        end
      end
    end

    if operator_document_fmus.none?
      RequiredOperatorDocumentFmu.where(country_id: country).find_each do |rodf|
        self.fmus.find_each do |fmu|
          OperatorDocumentFmu.where(required_operator_document_id: rodf.id, operator_id: id, fmu_id: fmu.id).first_or_create do |odf|
            odf.update!(status: OperatorDocument.statuses[:doc_not_provided], current: true)
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
