module V1
  class OperatorDocumentFmuResource < JSONAPI::Resource
    caching
    attributes :expire_date, :start_date, :status, :created_at, :updated_at, :attachment

    has_one :country
    has_one :fmu
    has_one   :operator
    has_one :required_operator_document
    has_one :required_operator_document_fmu
    has_many :documents

    filters :type, :status

    def custom_links(_)
      { self: nil }
    end
  end
end