require 'rails_helper'

RSpec.describe 'BioSample: validate via file', type: :request, authorized: true do
  let(:user_home_dir)  { Pathname.new(ENV.fetch('USER_HOME_DIR')) }
  let(:repository_dir) { Pathname.new(ENV.fetch('REPOSITORY_DIR')) }

  before do
    stub_request(:post, 'validator.example.com/api/validation').to_return_json(
      body: {
        status: 'accepted',
        uuid:   'deadbeef'
      }
    )

    stub_request(:get, 'validator.example.com/api/validation/deadbeef/status').to_return_json(
      {
        body: {status: 'accepted'}
      },
      {
        body: {status: 'running'}
      },
      {
        body: {status: 'finished'}
      }
    )

    stub_request(:get, 'validator.example.com/api/validation/deadbeef').to_return_json(
      body: {
        result: {
          validity: true,
          answer:   42
        }
      }
    )

    create :dway_user, uid: 'alice', api_key: 'API_KEY'

    FileUtils.touch user_home_dir.join('alice/foo').tap(&:mkpath).join('mysubmission.xml')
  end

  example do
    perform_enqueued_jobs do
      post '/api/validations/biosample/via-file', params: {
        BioSample: {file: uploaded_file(name: 'mybiosample.xml')}
      }
    end

    expect(response).to have_http_status(:created)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      request: {
        id:  an_instance_of(Integer),
        url: %r(\Ahttp://www.example.com/api/requests/\d+\z)
      }
    )

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status: 'finished',
      validity: 'valid',

      validation_reports: contain_exactly(
        {
          object_id: '_base',
          path:      nil,
          validity:  nil,
          details:   nil
        },
        {
          object_id: 'BioSample',
          path:      'mybiosample.xml',
          validity:  'valid',

          details: {
            validity: true,
            answer:   42
          }
        }
      ),

      submission: nil
    )

    expect(a_request(:post, 'validator.example.com/api/validation')).to have_been_made.times(1)
    expect(a_request(:get, 'validator.example.com/api/validation/deadbeef/status')).to have_been_made.times(3)
    expect(a_request(:get, 'validator.example.com/api/validation/deadbeef')).to have_been_made.times(1)
  end

  example do
    post '/api/validations/biosample/via-file', params: {
      BioSample: {path: '../foo/mybiosample.xml'}
    }

    expect(response).to have_http_status(:bad_request)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      error: /\Apath must be in \S+\z/
    )
  end
end
