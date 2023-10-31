require 'rails_helper'

RSpec.describe 'DRA: submit via file', type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  def uploaded_file(name:)
    Rack::Test::UploadedFile.new(StringIO.new, original_filename: name)
  end

  let(:default_headers) {
    {'X-Dway-User-ID': 'alice'}
  }

  let(:repository_dir) { Pathname.new(ENV.fetch('REPOSITORY_DIR')) }

  example 'without Analysis, valid' do
    perform_enqueued_jobs do
      post '/api/submissions/dra/via-file', params: {
        Submission: file_fixture_upload('dra/valid/example-0001_dra_Submission.xml'),
        Experiment: file_fixture_upload('dra/valid/example-0001_dra_Experiment.xml'),
        Run:        file_fixture_upload('dra/valid/example-0001_dra_Run.xml'),
        RunFile:    uploaded_file(name: 'runfile.xml')
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status: 'finished',
      validity: 'valid',

      validation_reports: {
        _base: {
          validity: nil,
          details:  nil
        },

        Submission: {
          validity: 'valid',
          details:  nil
        },

        Experiment: {
          validity: 'valid',
          details:  nil
        },

        Run: {
          validity: 'valid',
          details:  nil
        },

        RunFile: {
          validity: nil,
          details:  nil
        }
      },

      submission: {
        id: /\AX-\d+\z/
      }
    )

    submission_id  = response.parsed_body.dig(:submission, :id)
    submission_dir = repository_dir.join('alice/submissions', submission_id)

    expect(Dir.glob('**/*', base: submission_dir)).to match_array(%w(
      Experiment
      Experiment/example-0001_dra_Experiment.xml
      Experiment/validation-report.json
      Run
      Run/example-0001_dra_Run.xml
      Run/validation-report.json
      RunFile
      RunFile/runfile.xml
      RunFile/validation-report.json
      Submission
      Submission/example-0001_dra_Submission.xml
      Submission/validation-report.json
      _base
      _base/validation-report.json
      validation-report.json
    ))
  end

  example 'with Analysis, valid' do
    perform_enqueued_jobs do
      post '/api/submissions/dra/via-file', params: {
        Submission:   file_fixture_upload('dra/valid/example-0002_dra_Submission.xml'),
        Experiment:   file_fixture_upload('dra/valid/example-0002_dra_Experiment.xml'),
        Run:          file_fixture_upload('dra/valid/example-0002_dra_Run.xml'),
        RunFile:      uploaded_file(name: 'runfile.xml'),
        Analysis:     file_fixture_upload('dra/valid/example-0002_dra_Analysis.xml'),
        AnalysisFile: uploaded_file(name: 'analysisfile.xml')
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status: 'finished',
      validity: 'valid',

      validation_reports: {
        _base: {
          validity: nil,
          details:  nil
        },

        Submission: {
          validity: 'valid',
          details:  nil
        },

        Experiment: {
          validity: 'valid',
          details:  nil
        },

        Run: {
          validity: 'valid',
          details:  nil
        },

        RunFile: {
          validity: nil,
          details:  nil
        },

        Analysis: {
          validity: 'valid',
          details:  nil
        },

        AnalysisFile: {
          validity: nil,
          details:  nil
        }
      },

      submission: {
        id: /\AX-\d+\z/
      }
    )

    submission_id  = response.parsed_body.dig(:submission, :id)
    submission_dir = repository_dir.join('alice/submissions', submission_id)

    expect(Dir.glob('**/*', base: submission_dir)).to match_array(%w(
      Analysis
      Analysis/example-0002_dra_Analysis.xml
      Analysis/validation-report.json
      AnalysisFile
      AnalysisFile/analysisfile.xml
      AnalysisFile/validation-report.json
      Experiment
      Experiment/example-0002_dra_Experiment.xml
      Experiment/validation-report.json
      Run
      Run/example-0002_dra_Run.xml
      Run/validation-report.json
      RunFile
      RunFile/runfile.xml
      RunFile/validation-report.json
      Submission
      Submission/example-0002_dra_Submission.xml
      Submission/validation-report.json
      _base
      _base/validation-report.json
      validation-report.json
    ))
  end

  example 'without Analysis, invalid' do
    perform_enqueued_jobs do
      post '/api/submissions/dra/via-file', params: {
        Submission: file_fixture_upload('dra/invalid/example-0001_dra_Submission.xml'),
        Experiment: file_fixture_upload('dra/invalid/example-0001_dra_Experiment.xml'),
        Run:        file_fixture_upload('dra/invalid/example-0001_dra_Run.xml'),
        RunFile:    uploaded_file(name: 'runfile.xml')
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status: 'finished',
      validity: 'invalid',

      validation_reports: {
        _base: {
          validity: nil,
          details:  nil
        },

        Submission: {
          validity: 'invalid',

          details: [
            object_id: 'Submission',
            message:   '18:1: FATAL: Premature end of data in tag SUBMISSION line 2'
          ]
        },

        Experiment: {
          validity: 'invalid',

          details: [
            object_id: 'Experiment',
            message:   '167:1: FATAL: Premature end of data in tag EXPERIMENT_SET line 2'
          ]
        },

        Run: {
          validity: 'invalid',

          details: [
            object_id: 'Run',
            message:   '41:1: FATAL: Premature end of data in tag RUN_SET line 2'
          ]
        },

        RunFile: {
          validity: nil,
          details:  nil
        }
      },

      submission: nil
    )
  end

  example 'without Analysis, error' do
    allow(Open3).to receive(:capture2e) { ['Something went wrong.', double(success?: false)] }

    perform_enqueued_jobs do
      post '/api/submissions/dra/via-file', params: {
        Submission: file_fixture_upload('dra/valid/example-0001_dra_Submission.xml'),
        Experiment: file_fixture_upload('dra/valid/example-0001_dra_Experiment.xml'),
        Run:        file_fixture_upload('dra/valid/example-0001_dra_Run.xml'),
        RunFile:    uploaded_file(name: 'runfile.xml')
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status: 'finished',
      validity: 'error',

      validation_reports: {
        _base: {
          validity: 'error',

          details: {
            error: 'Something went wrong.'
          }
        },

        Submission: {
          validity: nil,
          details:  nil
        },

        Experiment: {
          validity: nil,
          details:  nil
        },

        Run: {
          validity: nil,
          details:  nil
        },

        RunFile: {
          validity: nil,
          details:  nil
        }
      },

      submission: nil
    )
  end
end
