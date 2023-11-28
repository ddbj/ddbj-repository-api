require 'rails_helper'

RSpec.describe MetabobankValidator, type: :model do
  example 'without MAF and RawDataFile and ProcessedDataFile, valid' do
    request = create(:request, db: 'MetaboBank') {|request|
      create :obj, request:, _id: '_base'
      create :obj, request:, _id: 'IDF',  file: fixture_file_upload('metabobank/MTBKS231.idf.txt')
      create :obj, request:, _id: 'SDRF', file: fixture_file_upload('metabobank/MTBKS231.sdrf.txt')
    }

    Validators.new(request).validate

    expect(request).to have_attributes(
      status:   'finished',
      validity: 'valid',

      validation_reports: contain_exactly(
        {
          object_id: '_base',
          path:      nil,
          validity:  'valid',
          details:   nil
        },
        {
          object_id: 'IDF',
          path:      'MTBKS231.idf.txt',
          validity:  'valid',

          details: [
            'object_id' => 'IDF',
            'code'      => 'MB_IR0037',
            'severity'  => 'error_ignore',
            'message'   => instance_of(String)
          ]
        },
        {
          object_id: 'SDRF',
          path:      'MTBKS231.sdrf.txt',
          validity:  'valid',
          details:   instance_of(Array)
        }
      )
    )
  end
end
