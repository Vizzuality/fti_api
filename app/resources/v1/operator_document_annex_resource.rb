module V1
  class OperatorDocumentAnnexResource < JSONAPI::Resource
    caching
    attributes :operator_document_id, :name,
               :start_date, :expire_date, :status, :attachment,
               :uploaded_by, :created_at, :updated_at

    has_one :operator_document
    has_one :user

    filters :status, :operator_document_id

    before_create :set_user_id, :set_status

    def set_user_id
      if context[:current_user].present?
        @model.user_id = context[:current_user].id
        @model.uploaded_by = :operator
      end
    end

    def set_status
      @model.status = OperatorDocumentAnnex.statuses[:doc_pending]
    end

    def custom_links(_)
      { self: nil }
    end

  end
end
