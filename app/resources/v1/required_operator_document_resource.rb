# frozen_string_literal: true

module V1
  class RequiredOperatorDocumentResource < JSONAPI::Resource
    include CacheableByLocale
    caching
    attributes :name, :valid_period, :explanation, :forest_types, :contract_signature

    has_one :country
    has_one :required_operator_document_group
    has_many :operator_documents
    has_many :operator_document_fmus
    has_many :operator_document_countries
    has_many :operator_document_histories
    has_many :operator_document_country_histories
    has_many :operator_document_fmu_histories

    filters :name, :type

    def custom_links(_)
      { self: nil }
    end

    def self.records(options={})
      RequiredOperatorDocument.unscoped
    end
  end
end
