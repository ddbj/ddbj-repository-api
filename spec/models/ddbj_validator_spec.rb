require 'rails_helper'

RSpec.describe DdbjValidator, type: :model do
  describe 'BioSample' do
    example do
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

      request = create(:request, db: 'BioSample') {|request|
        create :obj, request:, _id: 'BioSample', file: uploaded_file(name: 'mybiosample.xml')
      }

      Validators.new(request).validate

      expect(request).to have_attributes(
        status:   'finished',
        validity: 'valid'
      )

      expect(request.validation_reports).to contain_exactly(
        {
          object_id: '_base',
          path:      nil,
          validity:  'valid',
          details:   nil
        },
        {
          object_id: 'BioSample',
          path:      'mybiosample.xml',
          validity:  'valid',

          details: {
            'validity' => true,
            'answer'   => 42
          }
        }
      )

      expect(a_request(:post, 'validator.example.com/api/validation')).to have_been_made.times(1)
      expect(a_request(:get, 'validator.example.com/api/validation/deadbeef/status')).to have_been_made.times(3)
      expect(a_request(:get, 'validator.example.com/api/validation/deadbeef')).to have_been_made.times(1)
    end
  end
end
