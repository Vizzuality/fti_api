module V1
  class RequiredOperatorDocumentResource < JSONAPI::Resource
    caching
    attributes :name

    has_one :country
    has_one :required_operator_document_group
    has_many :operator_documents

    filters :name, :type

    def custom_links(_)
      { self: nil }
    end
  end
end
