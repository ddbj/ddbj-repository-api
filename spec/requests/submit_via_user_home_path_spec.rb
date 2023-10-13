require 'rails_helper'

RSpec.describe 'submit via user home path', type: :request do
  include FakeFS::SpecHelpers

  let(:default_headers) {
    {'X-Dway-User-ID': 'alice'}
  }

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

    FileUtils.mkdir_p 'path/to/home/alice/foo'

    FileUtils.touch %w(
      path/to/home/alice/foo/mybioproject.xml
      path/to/home/alice/foo/mysubmission.xml
    )
  end

  example do
    perform_enqueued_jobs do
      post '/api/bioproject/submit/via-user-home-path', params: {
        BioProject: 'foo/mybioproject.xml',
        Submission: 'foo/mysubmission.xml'
      }
    end

    expect(response).to have_http_status(:created)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      request_id: an_instance_of(Integer)
    )

    request_id = response.parsed_body.fetch(:request_id)

    get "/api/requests/#{request_id}/status"

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to eq(
      status: 'succeeded'
    )

    get "/api/requests/#{request_id}"

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status: 'succeeded',
      result: {
        validity: true,
        answer:   42
      },
      submission_id: an_instance_of(Integer)
    )

    submission_id = response.parsed_body.fetch(:submission_id)

    expect(File).to be_exist("path/to/repository/alice/submissions/#{submission_id}/BioProject/mybioproject.xml")
    expect(File).to be_exist("path/to/repository/alice/submissions/#{submission_id}/Submission/mysubmission.xml")
  end
end
