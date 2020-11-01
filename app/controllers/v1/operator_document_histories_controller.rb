# frozen_string_literal: true

module V1
  class OperatorDocumentHistoriesController < ApiController
    skip_before_action :authenticate, only: [:index, :show]
    load_and_authorize_resource class: 'OperatorDocumentHistory'

    def index
      result = SearchDocumentInTime.call(params)

      if result.success?
        super
      else
        return render json: { error: result.message }, status: :bad_request
      end
    end
  end
end
