require 'rails_helper'

RSpec.describe 'MetaboBank: submit via file', type: :request do
  let(:default_headers) {
    {'Authorization': 'Bearer TOKEN'}
  }

  let(:repository_dir) { Pathname.new(ENV.fetch('REPOSITORY_DIR')) }

  before do
    create :dway_user, uid: 'alice', api_token: 'TOKEN'
  end

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
        path:      'MTBKS231.idf.txt',
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
        MAF:  {file: file_fixture_upload('metabobank/MTBKS231.maf.txt')},

        RawDataFile:  [
          {file: uploaded_file(name: '010_10_1_010.lcd'),  destination: 'raw'},
          {file: uploaded_file(name: '011_11_4_011.lcd'),  destination: 'raw'},
          {file: uploaded_file(name: '012_12_7_012.lcd'),  destination: 'raw'},
          {file: uploaded_file(name: '013_13_10_013.lcd'), destination: 'raw'},
          {file: uploaded_file(name: '014_14_13_014.lcd'), destination: 'raw'},
          {file: uploaded_file(name: '015_15_16_015.lcd'), destination: 'raw'},
          {file: uploaded_file(name: '016_16_2_016.lcd'),  destination: 'raw'},
          {file: uploaded_file(name: '017_17_5_017.lcd'),  destination: 'raw'},
          {file: uploaded_file(name: '018_18_8_018.lcd'),  destination: 'raw'},
          {file: uploaded_file(name: '019_19_11_019.lcd'), destination: 'raw'},
          {file: uploaded_file(name: '020_20_14_020.lcd'), destination: 'raw'},
          {file: uploaded_file(name: '021_21_17_021.lcd'), destination: 'raw'},
          {file: uploaded_file(name: '022_22_3_022.lcd'),  destination: 'raw'},
          {file: uploaded_file(name: '023_23_6_023.lcd'),  destination: 'raw'},
          {file: uploaded_file(name: '024_24_9_024.lcd'),  destination: 'raw'},
          {file: uploaded_file(name: '025_25_12_025.lcd'), destination: 'raw'},
          {file: uploaded_file(name: '026_26_15_026.lcd'), destination: 'raw'},
          {file: uploaded_file(name: '027_27_18_027.lcd'), destination: 'raw'},
        ],

        ProcessedDataFile: [
          {file: uploaded_file(name: '220629_ppg_conc.txt'), destination: 'processed'},
        ]
      }
    end

    expect(response).to have_http_status(:created)

    get response.parsed_body.dig(:request, :url)

    expect(response).to have_http_status(:ok)

    expect(response.parsed_body.deep_symbolize_keys).to include(
      status:   'finished',
      validity: 'valid',

      validation_reports: include(
        include(
          object_id: 'RawDataFile',
          path:      'raw/010_10_1_010.lcd'
        ),

        include(
          object_id: 'ProcessedDataFile',
          path:      'processed/220629_ppg_conc.txt'
        )
      )
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
      RawDataFile/raw/010_10_1_010.lcd
      RawDataFile/raw/010_10_1_010.lcd-validation-report.json
      RawDataFile/raw/011_11_4_011.lcd
      RawDataFile/raw/011_11_4_011.lcd-validation-report.json
      RawDataFile/raw/012_12_7_012.lcd
      RawDataFile/raw/012_12_7_012.lcd-validation-report.json
      RawDataFile/raw/013_13_10_013.lcd
      RawDataFile/raw/013_13_10_013.lcd-validation-report.json
      RawDataFile/raw/014_14_13_014.lcd
      RawDataFile/raw/014_14_13_014.lcd-validation-report.json
      RawDataFile/raw/015_15_16_015.lcd
      RawDataFile/raw/015_15_16_015.lcd-validation-report.json
      RawDataFile/raw/016_16_2_016.lcd
      RawDataFile/raw/016_16_2_016.lcd-validation-report.json
      RawDataFile/raw/017_17_5_017.lcd
      RawDataFile/raw/017_17_5_017.lcd-validation-report.json
      RawDataFile/raw/018_18_8_018.lcd
      RawDataFile/raw/018_18_8_018.lcd-validation-report.json
      RawDataFile/raw/019_19_11_019.lcd
      RawDataFile/raw/019_19_11_019.lcd-validation-report.json
      RawDataFile/raw/020_20_14_020.lcd
      RawDataFile/raw/020_20_14_020.lcd-validation-report.json
      RawDataFile/raw/021_21_17_021.lcd
      RawDataFile/raw/021_21_17_021.lcd-validation-report.json
      RawDataFile/raw/022_22_3_022.lcd
      RawDataFile/raw/022_22_3_022.lcd-validation-report.json
      RawDataFile/raw/023_23_6_023.lcd
      RawDataFile/raw/023_23_6_023.lcd-validation-report.json
      RawDataFile/raw/024_24_9_024.lcd
      RawDataFile/raw/024_24_9_024.lcd-validation-report.json
      RawDataFile/raw/025_25_12_025.lcd
      RawDataFile/raw/025_25_12_025.lcd-validation-report.json
      RawDataFile/raw/026_26_15_026.lcd
      RawDataFile/raw/026_26_15_026.lcd-validation-report.json
      RawDataFile/raw/027_27_18_027.lcd
      RawDataFile/raw/027_27_18_027.lcd-validation-report.json
      ProcessedDataFile
      ProcessedDataFile/processed
      ProcessedDataFile/processed/220629_ppg_conc.txt
      ProcessedDataFile/processed/220629_ppg_conc.txt-validation-report.json
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
        path:      'MTBKS201.idf.txt',
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
        path:      'MTBKS231.bs.tsv',
        validity:  'valid',
        details:   nil
      ),

      submission: {
        id: /\AX-\d+\z/
      }
    )
  end
end
