require 'rails_helper'

RSpec.describe 'DRA: submit via file', type: :request, authorized: true do
  let(:repository_dir) { Pathname.new(ENV.fetch('REPOSITORY_DIR')) }

  before do
    create :dway_user, uid: 'alice', api_key: 'API_KEY'
  end

  xexample 'without Analysis, valid' do
    perform_enqueued_jobs do
      post '/api/submissions/dra/via-file', params: {
        Submission: {file: file_fixture_upload('dra/valid/example-0001_dra_Submission.xml')},
        Experiment: {file: file_fixture_upload('dra/valid/example-0001_dra_Experiment.xml')},
        Run:        {file: file_fixture_upload('dra/valid/example-0001_dra_Run.xml')},
        RunFile:    {file: uploaded_file(name: 'runfile.xml')}
      }
    end

    expect(response).to have_http_status(:created)

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
          object_id: 'Submission',
          path:      'example-0001_dra_Submission.xml',
          validity:  'valid',
          details:   nil
        },
        {
          object_id: 'Experiment',
          path:      'example-0001_dra_Experiment.xml',
          validity:  'valid',
          details:   nil
        },
        {
          object_id: 'Run',
          path:      'example-0001_dra_Run.xml',
          validity:  'valid',
          details:   nil
        },
        {
          object_id: 'RunFile',
          path:      'runfile.xml',
          validity:  nil,
          details:   nil
        }
      ),

      submission: {
        id: /\AX-\d+\z/
      }
    )

    submission_id  = response.parsed_body.dig(:submission, :id)
    submission_dir = repository_dir.join('alice/submissions', submission_id)

    expect(Dir.glob('**/*', base: submission_dir)).to match_array(%w(
      Experiment
      Experiment/example-0001_dra_Experiment.xml
      Experiment/example-0001_dra_Experiment.xml-validation-report.json
      Run
      Run/example-0001_dra_Run.xml
      Run/example-0001_dra_Run.xml-validation-report.json
      RunFile
      RunFile/runfile.xml
      RunFile/runfile.xml-validation-report.json
      Submission
      Submission/example-0001_dra_Submission.xml
      Submission/example-0001_dra_Submission.xml-validation-report.json
      _base
      _base/validation-report.json
      validation-report.json
    ))
  end

  xexample 'with Analysis, valid' do
    perform_enqueued_jobs do
      post '/api/submissions/dra/via-file', params: {
        Submission:   {file: file_fixture_upload('dra/valid/example-0002_dra_Submission.xml')},
        Experiment:   {file: file_fixture_upload('dra/valid/example-0002_dra_Experiment.xml')},
        Run:          {file: file_fixture_upload('dra/valid/example-0002_dra_Run.xml')},
        RunFile:      {file: uploaded_file(name: 'runfile.xml')},
        Analysis:     {file: file_fixture_upload('dra/valid/example-0002_dra_Analysis.xml')},
        AnalysisFile: {file: uploaded_file(name: 'analysisfile.xml')}
      }
    end

    expect(response).to have_http_status(:created)

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
          object_id: 'Submission',
          path:      'example-0002_dra_Submission.xml',
          validity:  'valid',
          details:   nil
        },
        {
          object_id: 'Experiment',
          path:      'example-0002_dra_Experiment.xml',
          validity:  'valid',
          details:   nil
        },
        {
          object_id: 'Run',
          path:      'example-0002_dra_Run.xml',
          validity:  'valid',
          details:   nil
        },
        {
          object_id: 'RunFile',
          path:      'runfile.xml',
          validity:  nil,
          details:   nil
        },
        {
          object_id: 'Analysis',
          path:      'example-0002_dra_Analysis.xml',
          validity:  'valid',
          details:   nil
        },
        {
          object_id: 'AnalysisFile',
          path:      'analysisfile.xml',
          validity:  nil,
          details:   nil
        }
      ),

      submission: {
        id: /\AX-\d+\z/
      }
    )

    submission_id  = response.parsed_body.dig(:submission, :id)
    submission_dir = repository_dir.join('alice/submissions', submission_id)

    expect(Dir.glob('**/*', base: submission_dir)).to match_array(%w(
      Analysis
      Analysis/example-0002_dra_Analysis.xml
      Analysis/example-0002_dra_Analysis.xml-validation-report.json
      AnalysisFile
      AnalysisFile/analysisfile.xml
      AnalysisFile/analysisfile.xml-validation-report.json
      Experiment
      Experiment/example-0002_dra_Experiment.xml
      Experiment/example-0002_dra_Experiment.xml-validation-report.json
      Run
      Run/example-0002_dra_Run.xml
      Run/example-0002_dra_Run.xml-validation-report.json
      RunFile
      RunFile/runfile.xml
      RunFile/runfile.xml-validation-report.json
      Submission
      Submission/example-0002_dra_Submission.xml
      Submission/example-0002_dra_Submission.xml-validation-report.json
      _base
      _base/validation-report.json
      validation-report.json
    ))
  end

  xexample 'without Analysis, invalid' do
    perform_enqueued_jobs do
      post '/api/submissions/dra/via-file', params: {
        Submission: {file: file_fixture_upload('dra/invalid/example-0001_dra_Submission.xml')},
        Experiment: {file: file_fixture_upload('dra/invalid/example-0001_dra_Experiment.xml')},
        Run:        {file: file_fixture_upload('dra/invalid/example-0001_dra_Run.xml')},
        RunFile:    {file: uploaded_file(name: 'runfile.xml')}
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status: 'finished',
      validity: 'invalid',

      validation_reports: contain_exactly(
        {
          object_id: '_base',
          path:      nil,
          validity:  nil,
          details:   nil
        },
        {
          object_id: 'Submission',
          path:      'example-0001_dra_Submission.xml',
          validity:  'invalid',

          details: [
            object_id: 'Submission',
            message:   '18:1: FATAL: Premature end of data in tag SUBMISSION line 2'
          ]
        },
        {
          object_id: 'Experiment',
          path:      'example-0001_dra_Experiment.xml',
          validity:  'invalid',

          details: [
            object_id: 'Experiment',
            message:   '167:1: FATAL: Premature end of data in tag EXPERIMENT_SET line 2',
          ]
        },
        {
          object_id: 'Run',
          path:      'example-0001_dra_Run.xml',
          validity:  'invalid',

          details: [
            object_id: 'Run',
            message:   '41:1: FATAL: Premature end of data in tag RUN_SET line 2',
          ]
        },
        {
          object_id: 'RunFile',
          path:      'runfile.xml',
          validity:  nil,
          details:   nil
        }
      ),

      submission: nil
    )
  end

  example 'without Analysis, error' do
    allow(Open3).to receive(:capture2e) { ['Something went wrong.', double(success?: false)] }

    perform_enqueued_jobs do
      post '/api/submissions/dra/via-file', params: {
        Submission: {file: file_fixture_upload('dra/valid/example-0001_dra_Submission.xml')},
        Experiment: {file: file_fixture_upload('dra/valid/example-0001_dra_Experiment.xml')},
        Run:        {file: file_fixture_upload('dra/valid/example-0001_dra_Run.xml')},
        RunFile:    {file: uploaded_file(name: 'runfile.xml')}
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status: 'finished',
      validity: 'error',

      validation_reports: contain_exactly(
        {
          object_id: '_base',
          path:      nil,
          validity:  'error',

          details: {
            error: 'Something went wrong.'
          }
        },
        {
          object_id: 'Submission',
          path:      'example-0001_dra_Submission.xml',
          validity:  nil,
          details:   nil
        },
        {
          object_id: 'Experiment',
          path:      'example-0001_dra_Experiment.xml',
          validity:  nil,
          details:   nil
        },
        {
          object_id: 'Run',
          path:      'example-0001_dra_Run.xml',
          validity:  nil,
          details:   nil
        },
        {
          object_id: 'RunFile',
          path:      'runfile.xml',
          validity:  nil,
          details:   nil
        }
      ),

      submission: nil
    )
  end

  example 'with multiple RunFile' do
    perform_enqueued_jobs do
      post '/api/submissions/dra/via-file', params: {
        Submission: {file: file_fixture_upload('dra/valid/example-0001_dra_Submission.xml')},
        Experiment: {file: file_fixture_upload('dra/valid/example-0001_dra_Experiment.xml')},
        Run:        {file: file_fixture_upload('dra/valid/example-0001_dra_Run.xml')},

        RunFile: [
          {file: uploaded_file(name: 'runfile1.xml')},
          {file: uploaded_file(name: 'runfile2.xml')}
        ]
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    submission_id  = response.parsed_body.dig(:submission, :id)
    submission_dir = repository_dir.join('alice/submissions', submission_id)

    expect(Dir.glob('**/*', base: submission_dir)).to match_array(%w(
      Experiment
      Experiment/example-0001_dra_Experiment.xml
      Experiment/example-0001_dra_Experiment.xml-validation-report.json
      Run
      Run/example-0001_dra_Run.xml
      Run/example-0001_dra_Run.xml-validation-report.json
      RunFile
      RunFile/runfile1.xml
      RunFile/runfile1.xml-validation-report.json
      RunFile/runfile2.xml
      RunFile/runfile2.xml-validation-report.json
      Submission
      Submission/example-0001_dra_Submission.xml
      Submission/example-0001_dra_Submission.xml-validation-report.json
      _base
      _base/validation-report.json
      validation-report.json
    ))
  end
end
