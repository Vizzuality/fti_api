require 'rails_helper'

module V1
  describe 'Species', type: :request do
    it_behaves_like "jsonapi-resources", Species, {
      route_key: 'species',
      show: {},
      create: {
        success_roles: %i[admin],
        failure_roles: %i[operator],
        valid_params: { name: 'Species one' },
        invalid_params: { name: '' },
        error_attributes: [422, 100, { 'name': ["can't be blank"] }]
      },
      edit: {
        success_roles: %i[admin],
        failure_roles: %i[user],
        valid_params: { name: 'Species one' },
        invalid_params: { name: '' },
        error_attributes: [422, 100, { 'name': ["can't be blank"] }]
      },
      delete: {
        success_roles: %i[admin],
        failure_roles: %i[user]
      },
      pagination: {},
      sort: {
        attribute: :name,
        sequence: -> (i) { "#{i} species" }
      }
    }
  end
end
