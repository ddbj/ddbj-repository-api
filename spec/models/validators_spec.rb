require 'rails_helper'

RSpec.describe Validators, type: :model do
  example 'happy case' do
    request = create(:request, db: 'JVar')

    Validators.new(request).validate

    expect(request).to have_attributes(
      status:   'finished',
      validity: 'valid'
    )
  end
end
