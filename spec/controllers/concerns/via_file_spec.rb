require 'rails_helper'

RSpec.describe ViaFile, type: :controller do
  controller ActionController::API do
    include ViaFile
  end

  let(:user) { create(:dway_user, uid: 'alice') }

  example 'simple' do
    params = ActionController::Parameters.new(
      db: 'biosample',

      BioSample: {
        file: uploaded_file(name: 'mybiosample.xml')
      }
    )

    request = controller.create_request_from_params(params, user)

    expect(request.objs.map(&:_id)).to contain_exactly('_base', 'BioSample')
  end

  example 'if path is directory, read recursive' do
    params = ActionController::Parameters.new(
      db: 'metabobank',

      IDF: {
        file: uploaded_file(name: 'myidf.txt')
      },

      SDRF: {
        file: uploaded_file(name: 'mysdrf.txt')
      },

      RawDataFile: {
        path: 'foo'
      },

      ProcessedDataFile: {
        path:        'foo',
        destination: 'dest'
      }
    )

    request = controller.create_request_from_params(params, user)

    expect(request.objs.map(&:_id)).to contain_exactly(
      '_base',
      'IDF',
      'SDRF',
      'RawDataFile',
      'RawDataFile',
      'ProcessedDataFile',
      'ProcessedDataFile'
    )

    expect(request.objs.select { _1._id == 'RawDataFile' }.map(&:path)).to contain_exactly(
      'bar',
      'baz/qux'
    )

    expect(request.objs.select { _1._id == 'ProcessedDataFile' }.map(&:path)).to contain_exactly(
      'dest/bar',
      'dest/baz/qux'
    )
  end
end
