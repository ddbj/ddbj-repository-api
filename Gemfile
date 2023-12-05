source 'https://rubygems.org'

ruby File.read(__dir__ + '/.ruby-version').chomp

gem 'rails', '~> 7.1.0'

gem 'base62-rb'
gem 'bootsnap', require: false
gem 'faraday'
gem 'faraday-multipart'
gem 'jb'
gem 'metabobank_tools', github: 'ddbj/metabobank_tools'
gem 'openid_connect'
gem 'parallel'
gem 'pg'
gem 'puma'
gem 'rack-cors'
gem 'sidekiq'
gem 'submission-excel2xml', github: 'ddbj/submission-excel2xml'

group :development do
  gem 'debug', group: :test
end

group :test do
  gem 'climate_control'
  gem 'factory_bot_rails', group: :development
  gem 'rspec-default_http_header'
  gem 'rspec-rails', group: :development
  gem 'webmock', require: 'webmock/rspec'
end
