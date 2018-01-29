# frozen_string_literal: true

module V1
  class RequiredOperatorDocumentResource < JSONAPI::Resource
    caching
    attributes :name, :valid_period, :explanation

    has_one :country
    has_one :required_operator_document_group
    has_many :operator_documents
    has_many :operator_document_fmus
    has_many :operator_document_countries

    filters :name, :type

    def custom_links(_)
      { self: nil }
    end
  end
end
