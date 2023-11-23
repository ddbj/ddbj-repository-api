require 'rails_helper'

RSpec.describe 'API key' do
  describe 'GET /api/api-key' do
    example do
      get '/api/api-key'

      expect(response).to have_http_status(:ok)

      expect(response.parsed_body.deep_symbolize_keys).to eq(
        login_url: 'http://www.example.com/auth/login'
      )
    end
  end

  describe 'POST /api/api-key/regenerate' do
    let(:default_headers) {
      {
        Authorization: 'Bearer API_KEY'
      }
    }

    let!(:user) { create(:dway_user, api_key: 'API_KEY') }

    before do
      allow(DwayUser).to receive(:generate_api_key) { 'NEW_API_KEY' }
    end

    example do
      post '/api/api-key/regenerate'

      expect(response).to have_http_status(:ok)

      expect(response.parsed_body.deep_symbolize_keys).to eq(
        api_key: 'NEW_API_KEY'
      )

      expect(user.reload).to have_attributes(
        api_key: 'NEW_API_KEY'
      )
    end
  end
end
