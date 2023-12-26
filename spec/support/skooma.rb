spec = Rails.root.join('doc/openapi.yaml')

RSpec.configure do |config|
  config.include Skooma::RSpec[spec], type: :request
end
