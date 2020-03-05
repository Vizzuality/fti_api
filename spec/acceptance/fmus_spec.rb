require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource 'Fmus' do
  explanation "FMUs resource"

  web_user = User.find_by(name: 'Web user')
  web_token = web_user.api_key.access_token

  header "Content-Type", "application/vnd.api+json"

  authentication :apiKey, "Bearer #{web_token}" , name: 'OTP-API-KEY'

  get "/fmus" do
    example "Listing fmus" do
      do_request

      expect(status).to eq 200
    end
  end
end