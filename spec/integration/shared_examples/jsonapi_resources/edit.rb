RSpec.shared_examples 'jsonapi-resources__edit' do |options|
  context "Edit" do
    let(:resource) { create(@singular.to_sym) }
    let(:route) { "/#{@route_key}/#{resource.id}" }
    let(:valid_params) { try_to_call(options[:valid_params]) }
    let(:invalid_params) { try_to_call(options[:invalid_params]) }

    (options[:success_roles] || [:webuser]).each do |role|
      describe "For user with #{role} role" do
        let(:headers) { respond_to?("#{role}_headers") ? send("#{role}_headers") : authorize_headers(create(role).id) }

        it "Returns error object when cannot be updated by admin" do
          patch(route,
                params: jsonapi_params(@collection, resource.id, invalid_params),
                headers: headers)

          expect(parsed_body).to eq(jsonapi_errors(*options[:error_attributes]))
          expect(status).to eq(422)
        end

        it "Returns success object when was successfully updated by admin" do
          patch(route,
                params: jsonapi_params(@collection, resource.id, valid_params),
                headers: headers)

          expect(status).to eq(200)
          valid_params
            .except(:relationships)
            .except(*options[:excluded_params])
            .each { |name, value| expect(parsed_attributes[name]).to eq(value) }
        end
      end
    end

    (options[:failure_roles] || [:webuser]).each do |role|
      describe "For user with #{role} role" do
        let(:headers) { respond_to?("#{role}_headers") ? send("#{role}_headers") : authorize_headers(create(role).id) }

        it "Do not allows to update by not admin user" do
          patch(route,
                params: jsonapi_params(@collection, resource.id, valid_params),
                headers: headers)

          expect(parsed_body).to eq(default_status_errors(401))
          expect(status).to eq(401)
        end
      end
    end

  end
end
