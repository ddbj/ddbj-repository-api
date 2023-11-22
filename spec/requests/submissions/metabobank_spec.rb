require 'rails_helper'

RSpec.describe 'MetaboBank: submit via file', type: :request do
  let(:default_headers) {
    {'X-Dway-User-ID': 'alice'}
  }

  let(:repository_dir) { Pathname.new(ENV.fetch('REPOSITORY_DIR')) }

  example 'without MAF and RawDataFile and ProcessedDataFile, valid' do
    perform_enqueued_jobs do
      post '/api/submissions/metabobank/via-file', params: {
        IDF:  {file: file_fixture_upload('metabobank/MTBKS231.idf.txt')},
        SDRF: {file: file_fixture_upload('metabobank/MTBKS231.sdrf.txt')}
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status:   'finished',
      validity: 'valid',

      validation_reports: include(
        object_id: 'IDF',
        filename:  'MTBKS231.idf.txt',
        validity:  'valid',

        details: include(
          object_id: 'IDF',
          severity:  'error_ignore',
          code:      'MB_IR0037',
          message:   'Every submitter should have an email address. The email address is not displayed publicly. If the persons are not appropriate for submitters, please list them in the Comment[Contributor] field as free-text.: Fumiaki Obata,Hina Kosakamoto'
        )
      ),

      submission: {
        id: /\AX-\d+\z/
      }
    )
  end

  example 'with MAF and RawDataFile and ProcessedDataFile, valid' do
    perform_enqueued_jobs do
      post '/api/submissions/metabobank/via-file', params: {
        IDF:  {file: file_fixture_upload('metabobank/MTBKS231.idf.txt')},
        SDRF: {file: file_fixture_upload('metabobank/MTBKS231.sdrf.txt')},
        MAF:  {file: uploaded_file(name: 'MTBKS231.maf.txt')},

        RawDataFile:  [
          {file: uploaded_file(name: 'raw1.txt'), destination: 'raw'},
          {file: uploaded_file(name: 'raw2.txt'), destination: 'raw'}
        ],

        ProcessedDataFile: [
          {file: uploaded_file(name: 'processed1.txt'), destination: 'processed'},
          {file: uploaded_file(name: 'processed2.txt'), destination: 'processed'}
        ]
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to include(
      status:   'finished',
      validity: 'valid'
    )

    submission_id  = response.parsed_body.dig(:submission, :id)
    submission_dir = repository_dir.join('alice/submissions', submission_id)

    expect(Dir.glob('**/*', base: submission_dir)).to match_array(%w(
      IDF
      IDF/MTBKS231.idf.txt
      IDF/MTBKS231.idf.txt-validation-report.json
      SDRF
      SDRF/MTBKS231.sdrf.txt
      SDRF/MTBKS231.sdrf.txt-validation-report.json
      MAF
      MAF/MTBKS231.maf.txt
      MAF/MTBKS231.maf.txt-validation-report.json
      RawDataFile
      RawDataFile/raw
      RawDataFile/raw/raw1.txt
      RawDataFile/raw/raw1.txt-validation-report.json
      RawDataFile/raw/raw2.txt
      RawDataFile/raw/raw2.txt-validation-report.json
      ProcessedDataFile
      ProcessedDataFile/processed
      ProcessedDataFile/processed/processed1.txt
      ProcessedDataFile/processed/processed1.txt-validation-report.json
      ProcessedDataFile/processed/processed2.txt
      ProcessedDataFile/processed/processed2.txt-validation-report.json
      _base
      _base/validation-report.json
      validation-report.json
    ))
  end

  example 'without MAF and RawDataFile and ProcessedDataFile, invalid' do
    perform_enqueued_jobs do
      post '/api/submissions/metabobank/via-file', params: {
        IDF:  {file: file_fixture_upload('metabobank/MTBKS201.idf.txt')},
        SDRF: {file: file_fixture_upload('metabobank/MTBKS201.sdrf.txt')}
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status:   'finished',
      validity: 'invalid',

      validation_reports: include(
        object_id: 'IDF',
        filename:  'MTBKS201.idf.txt',
        validity:  'valid',

        details: include(
          object_id: 'IDF',
          code:      'MB_IR0004',
          severity:  'error_ignore',
          message:   'Undefined field name: MTBKS201.idf.txt: Comment[Related resource]'
        )
      ),

      submission: nil
    )
  end

  example 'with BioSample, valid' do
    perform_enqueued_jobs do
      post '/api/submissions/metabobank/via-file', params: {
        IDF:       {file: file_fixture_upload('metabobank/MTBKS231.idf.txt')},
        SDRF:      {file: file_fixture_upload('metabobank/MTBKS231.sdrf.txt')},
        BioSample: {file: file_fixture_upload('metabobank/MTBKS231.bs.tsv')}
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status:   'finished',
      validity: 'valid',

      validation_reports: include(
        object_id: 'BioSample',
        filename:  'MTBKS231.bs.tsv',
        validity:  'valid',
        details:   nil
      ),

      submission: {
        id: /\AX-\d+\z/
      }
    )
  end
end
