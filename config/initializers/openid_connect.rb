OpenIDConnect.logger = Rails.logger
Rack::OAuth2.logger  = Rails.logger
WebFinger.logger     = Rails.logger
SWD.logger           = Rails.logger

SWD.url_builder = URI::HTTP if Rails.env.local?

OIDC_CONFIG = OpenIDConnect::Discovery::Provider::Config.discover!(ENV.fetch('OIDC_ISSUER_URL'))
