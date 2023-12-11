require 'rails_helper'

RSpec.describe Validators, type: :model do
  example 'cancel request' do
    request   = create(:request, db: 'BioProject')
    validator = double(:validator)

    allow(validator).to receive(:validate) { request.canceled! }

    stub_const 'Validators::VALIDATOR', 'ddbj' => validator

    on_finish_called = false

    Validators.new(request).validate do
      on_finish_called = true
    end

    expect(request.status).to eq('canceled')
    expect(request.validity).to be_nil
    expect(on_finish_called).to eq(false)
  end
end
