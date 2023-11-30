require 'rails_helper'

RSpec.describe DraValidator, type: :model do
  example 'valid' do
    request = create(:request, db: 'DRA') {|request|
      create :obj, request:, _id: '_base',      file: file_fixture_upload('dra/valid/example-0001_dra_Submission.xml')
      create :obj, request:, _id: 'Submission', file: file_fixture_upload('dra/valid/example-0001_dra_Submission.xml')
      create :obj, request:, _id: 'Experiment', file: file_fixture_upload('dra/valid/example-0001_dra_Experiment.xml')
      create :obj, request:, _id: 'Run',        file: file_fixture_upload('dra/valid/example-0001_dra_Run.xml')
      create :obj, request:, _id: 'RunFile',    file: uploaded_file(name: 'runfile.xml')
    }

    Validators.new(request).validate

    expect(request).to have_attributes(
      status: 'finished',
      validity: 'valid',

      validation_reports: contain_exactly(
        {
          object_id: '_base',
          path:      nil,
          validity:  'valid',
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
          validity:  'valid',
          details:   nil
        }
      )
    )
  end

  example 'invalid' do
    request = create(:request, db: 'DRA') {|request|
      create :obj, request:, _id: '_base',      file: file_fixture_upload('dra/invalid/example-0001_dra_Submission.xml')
      create :obj, request:, _id: 'Submission', file: file_fixture_upload('dra/invalid/example-0001_dra_Submission.xml')
      create :obj, request:, _id: 'Experiment', file: file_fixture_upload('dra/invalid/example-0001_dra_Experiment.xml')
      create :obj, request:, _id: 'Run',        file: file_fixture_upload('dra/invalid/example-0001_dra_Run.xml')
      create :obj, request:, _id: 'RunFile',    file: uploaded_file(name: 'runfile.xml')
    }

    Validators.new(request).validate

    expect(request).to have_attributes(
      status:   'finished',
      validity: 'invalid'
    )

    expect(request.validation_reports).to contain_exactly(
      {
        object_id: '_base',
        path:      nil,
        validity:  'valid',
        details:   nil
      },
      {
        object_id: 'Submission',
        path:      'example-0001_dra_Submission.xml',
        validity:  'invalid',

        details: [
          'object_id' => 'Submission',
          'message'   => '18:1: FATAL: Premature end of data in tag SUBMISSION line 2'
        ]
      },
      {
        object_id: 'Experiment',
        path:      'example-0001_dra_Experiment.xml',
        validity:  'invalid',
        details:   instance_of(Array)
      },
      {
        object_id: 'Run',
        path:      'example-0001_dra_Run.xml',
        validity:  'invalid',
        details:   instance_of(Array)
      },
      {
        object_id: 'RunFile',
        path:      'runfile.xml',
        validity:  'valid',
        details:   nil
      }
    )
  end

  example 'error' do
  end

  example 'with Analysis, valid' do
  end

  example 'with multiple RunFile, valid' do
  end
end
