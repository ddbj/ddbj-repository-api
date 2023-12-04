require 'rails_helper'

RSpec.describe ValidateJob, type: :job do
  let(:alice) { create(:dway_user, uid: 'alice') }

  example do
    request = create(:request, db: 'MetaboBank', dway_user: alice) {|request|
      create :obj, request:, _id: '_base'
      create :obj, request:, _id: 'IDF',  file: file_fixture_upload('metabobank/valid/MTBKS231.idf.txt')
      create :obj, request:, _id: 'SDRF', file: file_fixture_upload('metabobank/valid/MTBKS231.sdrf.txt')
    }

    ValidateJob.perform_now request

    expect(request).to have_attributes(
      status:   'finished',
      validity: 'valid'
    )
  end
end
