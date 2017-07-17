module V1
  class RequiredOperatorDocumentFmuResource < JSONAPI::Resource
    caching
    attributes :name, :type

    has_one :country
    has_one :required_operator_document_group
    has_many :operator_document_countries

    filters :name, :type

    def custom_links(_)
      { self: nil }
    end
  end
end