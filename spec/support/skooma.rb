spec = Rails.root.join('doc/openapi.yaml')

RSpec.configure do |config|
  config.include Skooma::RSpec[spec, path_prefix: '/api'], type: :request
end
