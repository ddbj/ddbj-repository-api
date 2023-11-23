require 'rails_helper'

RSpec.describe 'me', type: :request, authorized: true do
  before do
    create :dway_user, uid: 'alice', api_key: 'API_KEY'
  end

  example do
    get '/api/me'

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to eq(
      uid: 'alice'
    )
  end
end
