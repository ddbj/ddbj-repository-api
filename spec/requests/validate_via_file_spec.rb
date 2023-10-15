require 'rails_helper'

RSpec.describe 'validate via file', type: :request do
  def uploaded_file(name:)
    Rack::Test::UploadedFile.new(StringIO.new, original_filename: name)
  end

  let(:default_headers) {
    {'X-Dway-User-ID': 'alice'}
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

    FileUtils.touch user_home_dir.join('alice/foo').tap(&:mkpath).join('mysubmission.xml')
  end

  example do
    perform_enqueued_jobs do
      post '/api/bioproject/validate/via-file', params: {
        BioProject: uploaded_file(name: 'mybioproject.xml'),
        Submission: '~/foo/mysubmission.xml'
      }
    end

    expect(response).to have_http_status(:created)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      request: {
        id:  an_instance_of(Integer),
        url: %r(\Ahttp://www.example.com/api/requests/\d+\z)
      }
    )

    request_id  = response.parsed_body.dig(:request, :id)
    request_dir = repository_dir.join('alice/requests', request_id.to_s)

    expect(Dir.glob('**/*', base: request_dir)).to match_array(%w(
      validation-report.json
      BioProject
      BioProject/mybioproject.xml
      Submission
      Submission/mysubmission.xml
    ))

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to eq(
      status: 'succeeded',
      result: {
        validity: true,
        answer:   42
      },
      submission: nil
    )
  end

  example do
    post '/api/bioproject/validate/via-file', params: {
      BioProject: uploaded_file(name: 'mybioproject.xml'),
      Submission: 'foo/mysubmission.xml'
    }

    expect(response).to have_http_status(:bad_request)

    expect(response.parsed_body.deep_symbolize_keys).to eq(
      error: 'unexpected parameter format in Submission: "foo/mysubmission.xml"'
    )
  end

  example do
    post '/api/bioproject/validate/via-file', params: {
      BioProject: uploaded_file(name: 'mybioproject.xml'),
      Submission: '~/../foo/mysubmission.xml'
    }

    expect(response).to have_http_status(:bad_request)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      error: /\Apath must be in \S+\z/
    )
  end
end
