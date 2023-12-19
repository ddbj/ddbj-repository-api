require 'rails_helper'

RSpec.describe 'requests', type: :request, authorized: true do
  before do
    user = create(:user, api_key: 'API_KEY')

    create :request, user:, id: 100, status: 'finished' do |request|
      create :submission, request:, user:, id: 200
    end

    create :request, user:, id: 101, status: 'waiting'
  end

  example 'GET /api/requests' do
    get '/api/requests', as: :json

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.map(&:deep_symbolize_keys)).to match([
      {
        id:         100,
        url:        'http://www.example.com/api/requests/100',
        created_at: instance_of(String),
        status:     'finished',
        validity:   nil,

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
        id:         101,
        url:        'http://www.example.com/api/requests/101',
        created_at: instance_of(String),
        status:     'waiting',
        validity:   nil,

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

    expect(response.parsed_body.deep_symbolize_keys).to match(
      id:         100,
      url:        'http://www.example.com/api/requests/100',
      created_at: instance_of(String),
      status:     'finished',
      validity:   nil,

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

  describe 'DELETE /api/requests/:id' do
    example 'if request is waiting' do
      delete '/api/requests/101'

      expect(response).to have_http_status(:no_content)
    end

    example 'if request is finished' do
      delete '/api/requests/100'

      expect(response).to have_http_status(:conflict)
    end
  end
end
