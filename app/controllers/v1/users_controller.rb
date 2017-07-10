# frozen_string_literal: true

module V1
  class UsersController < ApplicationController
    include ErrorSerializer

    load_and_authorize_resource class: 'User'

    def current
      user = User.find(context[:current_user])
      render json: JSONAPI::ResourceSerializer.new(UserResource).serialize_to_hash(UserResource.new(user, context))
    end
  end
end
