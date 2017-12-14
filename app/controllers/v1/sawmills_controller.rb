module V1
  class SawmillsController < ApiController
    skip_before_action :authenticate, only: [:index, :show]
    load_and_authorize_resource class: 'Sawmill'
  end
end
