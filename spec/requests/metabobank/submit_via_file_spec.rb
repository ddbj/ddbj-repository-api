require 'rails_helper'

RSpec.describe 'MetaboBank: submit via file', type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  let(:default_headers) {
    {'X-Dway-User-ID': 'alice'}
  }

  example 'without MAF and RawDataFile and ProcessedDataFile, valid' do
    perform_enqueued_jobs do
      post '/api/submissions/metabobank/via-file', params: {
        IDF:  file_fixture_upload('metabobank/MTBKS231.idf.txt'),
        SDRF: file_fixture_upload('metabobank/MTBKS231.sdrf.txt')
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status:   'finished',
      validity: 'valid',

      validation_reports: include(
        objectId: 'IDF',
        filename: 'MTBKS231.idf.txt',
        validity: 'valid',

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

  example 'with MAF and RawDataFile and ProcessedDataFile, valid'

  example 'without MAF and RawDataFile and ProcessedDataFile, invalid' do
    perform_enqueued_jobs do
      post '/api/submissions/metabobank/via-file', params: {
        IDF: file_fixture_upload('metabobank/MTBKS201.idf.txt'),
        SDRF: file_fixture_upload('metabobank/MTBKS201.sdrf.txt')
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to match(
      status:   'finished',
      validity: 'invalid',

      validation_reports: include(
        objectId: 'IDF',
        filename: 'MTBKS201.idf.txt',
        validity: 'valid',

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
end
