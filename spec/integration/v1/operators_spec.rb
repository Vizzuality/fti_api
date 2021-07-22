require 'rails_helper'

module V1
  describe 'Operator', type: :request do
    let(:country) { create(:country) }

    it_behaves_like "jsonapi-resources", Operator, {
      show: {},
      create: {
        success_roles: %i[admin user webuser],
        failure_roles: [],
        valid_params: -> { { name: 'Operator one', 'operator-type': 'Other', relationships: { country: country.id } } },
        invalid_params: { name: '', 'operator-type': 'Other' },
        error_attributes: [422, 100, { name: ["can't be blank"], relationships_country: ["can't be blank"] }]
      },
      edit: {
        success_roles: %i[admin],
        failure_roles: %i[user],
        valid_params: { name: 'Operator one', 'operator-type': 'Other' },
        invalid_params: { name: '', 'operator-type': 'Other',  },
        error_attributes: [422, 100, { name: ["can't be blank"] }]
      },
      delete: {
        success_roles: %i[admin],
        failure_roles: %i[user]
      },
      pagination: {},
      sort: {
        attribute: :name,
        sequence: -> (i) { "#{i} operator" }
      }
    }

    context 'Edit operators' do
      let(:photo_data) do
        "data:image/jpeg;base64,#{Base64.encode64(File.read(File.join(Rails.root, 'spec', 'support', 'files', 'image.png')))}"
      end

      let(:operator) { create(:operator) }

      describe 'For admin user' do
        it 'Upload logo and returns success object when the operator was successfully updated by admin' do
          patch("/operators/#{operator.id}",
                params: jsonapi_params('operators', operator.id, { logo: photo_data }),
                headers: admin_headers)

          expect(status).to eq(200)
          expect(parsed_attributes[:logo]).to_not be_empty
          expect(parsed_attributes.dig(:logo, :url)).to include("operator/logo/#{operator.id}/logo.png")
        end
      end
    end
  end
end
