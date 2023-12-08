require 'rails_helper'

RSpec.describe 'requests', type: :request, authorized: true do
  before do
    dway_user = create(:dway_user, api_key: 'API_KEY')

    create :request, dway_user:, id: 100, status: 'finished' do |request|
      create :submission, request:, dway_user:, id: 200
    end

    create :request, dway_user:, id: 101, status: 'waiting'
  end

  example 'GET /api/requests' do
    get '/api/requests', as: :json

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.map(&:deep_symbolize_keys)).to eq([
      {
        id:       100,
        url:      'http://www.example.com/api/requests/100',
        status:   'finished',
        validity: nil,

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
      },
      {
        id:       101,
        url:      'http://www.example.com/api/requests/101',
        status:   'waiting',
        validity: nil,

        validation_reports: [
          {
            object_id: '_base',
            path:      nil,
            validity:  nil,
            details:   nil
          }
        ],

        submission: nil
      }
    ])
  end

  example 'GET /api/requests/:id' do
    get '/api/requests/100', as: :json

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to eq(
      id:       100,
      url:      'http://www.example.com/api/requests/100',
      status:   'finished',
      validity: nil,

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
