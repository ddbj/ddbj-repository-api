require 'rails_helper'

RSpec.describe DestroyStaledRequestsJob, type: :job do
  let(:user) { create_default(:user) }

  example do
    travel_to '2023-01-01'

    req1 = create(:request, created_at: '2022-01-01')
    req2 = create(:request, created_at: '2022-01-02')

    req3 = create(:request, created_at: '2022-01-01') {|request|
      create :submission, request:
    }

    DestroyStaledRequestsJob.perform_now

    expect(Request.all).to contain_exactly(req2, req3)
  end
end
