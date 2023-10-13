require 'rails_helper'

RSpec.describe 'submit via file', type: :request do
  include FakeFS::SpecHelpers

  def uploaded_file(name:)
    Rack::Test::UploadedFile.new(StringIO.new, original_filename: name)
  end

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
    FileUtils.touch   'path/to/home/alice/foo/mysubmission.xml'
  end

  example do
    perform_enqueued_jobs do
      post '/api/bioproject/submit/via-file', params: {
        BioProject: uploaded_file(name: 'mybioproject.xml'),
        Submission: 'foo/mysubmission.xml'
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
      status: 'succeeded',
      result: {
        validity: true,
        answer:   42
      },
      submission: {
        id: an_instance_of(Integer)
      }
    )

    submission_id  = response.parsed_body.dig(:submission, :id)
    submission_dir = Pathname.new('path/to/repository/alice/submissions').join(submission_id.to_s)

    expect(submission_dir.join('BioProject/mybioproject.xml')).to be_exist
    expect(submission_dir.join('Submission/mysubmission.xml')).to be_exist
  end
end
