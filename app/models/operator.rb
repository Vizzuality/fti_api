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
#  is_active                          :boolean          default(TRUE)
#  logo                               :string
#  operator_id                        :string
#  percentage_valid_documents_all     :float
#  percentage_valid_documents_country :float
#  percentage_valid_documents_fmu     :float
#

class Operator < ApplicationRecord
  translates :name, :details

  mount_base64_uploader :logo, LogoUploader

  belongs_to :country, inverse_of: :operators, optional: true

  has_many :observations, inverse_of: :operator
  has_many :user_operators
  has_many :users, through: :user_operators
  has_many :fmus, inverse_of: :operator

  has_many :operator_documents
  has_many :operator_document_countries
  has_many :operator_document_fmus

  after_create :create_operator_id
  after_create :create_documents

  validates :name, presence: true

  scope :by_name_asc, -> {
    includes(:translations).with_translations(I18n.available_locales)
                           .order('operator_translations.name ASC')
  }

  default_scope { includes(:translations) }

  scope :filter_by_country_ids,   ->(country_ids)     { where(country_id: country_ids.split(',')) }

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
      %w(Logging\ Company Artisanal Sawmill CommunityForest ARB1327 PalmOil Trader Company).freeze
    end

    def translated_types
      types.map { |t| [I18n.t("operator_types.#{t}", default: t), t.camelize] }
    end
  end

  def cache_key
    super + '-' + Globalize.locale.to_s
  end

  def update_valid_documents_percentages
    all = (operator_documents.where(status: 2).count / operator_documents.count).to_f rescue 0
    fmu = (operator_documents.where(type: 'OperatorDocumentFmu', status: 2).count / operator_documents.where(type: 'OperatorDocumentFmu').count).to_f rescue 0
    country = (operator_documents.where(type: 'OperatorDocumentCountry', status: 2).count / operator_documents.where(type: 'OperatorDocumentCountry').count).to_f rescue 0

    self.update_attributes(percentage_valid_documents_all: all, percentage_valid_documents_country: country, percentage_valid_documents_fmu: fmu)
  end

  private

  def create_operator_id
    if country_id.present?
      update_columns(operator_id: "#{country.iso}-unknown-#{id}")
    else
      update_columns(operator_id: "na-unknown-#{id}")
    end
  end

  def create_documents
    country = RequiredOperatorDocument.where(country_id: country_id).any? ? country_id : nil

    RequiredOperatorDocumentCountry.where(country_id: country).find_each do |rodc|
      OperatorDocumentCountry.where(required_operator_document_id: rodc.id, operator_id: id).first_or_create do |odc|
        odc.update_attributes!(status: OperatorDocument.statuses[:doc_not_provided])
      end
    end

    RequiredOperatorDocumentFmu.where(country_id: country).find_each do |rodf|
      Fmu.where(operator_id: id).find_each do |fmu|
        OperatorDocumentFmu.where(required_operator_document_id: rodf.id, operator_id: id, fmu_id: fmu.id).first_or_create do |odf|
          odf.update_attributes!(status: OperatorDocument.statuses[:doc_not_provided])
        end
      end
    end

  end

end
