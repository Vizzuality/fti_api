module V1
  class OperatorDocumentCountriesController < ApiController
    skip_before_action :authenticate, only: [:index, :show]
    load_and_authorize_resource class: 'OperatorDocument'
  end
end
