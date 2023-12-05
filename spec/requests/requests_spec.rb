require 'rails_helper'

RSpec.describe 'requests', type: :request, authorized: true do
  example do
    dway_user = create(:dway_user, api_key: 'API_KEY')

    create :request, dway_user:, id: 100, status: 'finished' do |request|
      create :submission, request:, dway_user:, id: 200
    end

    get '/api/requests/100', as: :json

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to eq(
      status:   'finished',
      validity: 'valid',

      validation_reports: [
        {
          object_id: '_base',
          path:      nil,
          validity:  nil,
          details:   nil
        }
      ],

      submission: {
        id:  'X-200',
        url: 'http://www.example.com/api/submissions/X-200'
      }
    )
  end
end
