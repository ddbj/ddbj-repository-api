source 'https://rubygems.org'

ruby File.read('.ruby-version').chomp

gem 'rails', '~> 7.1.0'

gem 'bootsnap', require: false
gem 'faraday'
gem 'faraday-multipart'
gem 'pg'
gem 'puma'
gem 'sidekiq'

group :development do
  gem 'debug', group: :test
end

group :test do
  gem 'climate_control'
  gem 'rspec-default_http_header'
  gem 'rspec-rails', group: :development
  gem 'webmock', require: 'webmock/rspec'
end
