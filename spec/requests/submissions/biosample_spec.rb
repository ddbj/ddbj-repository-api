require 'rails_helper'

RSpec.describe 'BioSample: submit via file', type: :request do
  let(:default_headers) {
    {'Authorization': 'Bearer TOKEN'}
  }

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

    create :dway_user, uid: 'alice', api_token: 'TOKEN'

    FileUtils.touch user_home_dir.join('alice/foo').tap(&:mkpath).join('mysubmission.xml')
  end

  example do
    perform_enqueued_jobs do
      post '/api/submissions/biosample/via-file', params: {
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

      submission: {
        id: /\AX-\d+\z/
      }
    )

    expect(a_request(:post, 'validator.example.com/api/validation')).to have_been_made.times(1)
    expect(a_request(:get, 'validator.example.com/api/validation/deadbeef/status')).to have_been_made.times(3)
    expect(a_request(:get, 'validator.example.com/api/validation/deadbeef')).to have_been_made.times(1)

    submission_id  = response.parsed_body.dig(:submission, :id)
    submission_dir = repository_dir.join('alice/submissions', submission_id)

    expect(Dir.glob('**/*', base: submission_dir)).to match_array(%w(
      BioSample
      BioSample/mybiosample.xml
      BioSample/mybiosample.xml-validation-report.json
      _base
      _base/validation-report.json
      validation-report.json
    ))
  end

  example do
    post '/api/submissions/biosample/via-file', params: {
      BioSample: {path: '../foo/mybiosample.xml'}
    }

    expect(response).to have_http_status(:bad_request)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      error: /\Apath must be in \S+\z/
    )
  end

  example do
    post '/api/submissions/biosample/via-file', params: {
      BioSample: {
        file:        uploaded_file(name: 'mybiosample.xml'),
        destination: '..'
      }
    }

    expect(response).to have_http_status(:unprocessable_entity)

    expect(response.parsed_body.deep_symbolize_keys).to eq(
      error: 'Validation failed: Destination is malformed path'
    )
  end
end
