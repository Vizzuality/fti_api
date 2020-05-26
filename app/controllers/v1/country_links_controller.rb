# frozen_string_literal: true

module V1
  class CountryLinksController < ApiController
    include ErrorSerializer

    skip_before_action :authenticate, only: [:index, :show]
    load_and_authorize_resource class: 'CountryLink'

  end
end
