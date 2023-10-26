source 'https://rubygems.org'

ruby File.read(__dir__ + '/.ruby-version').chomp

gem 'rails', '~> 7.1.0'

gem 'bootsnap', require: false
gem 'faraday'
gem 'faraday-multipart'
gem 'parallel'
gem 'pg'
gem 'puma'
gem 'sidekiq'
gem 'submission-excel2xml', github: 'ddbj/submission-excel2xml', branch: 'repository'

group :development do
  gem 'debug', group: :test
end

group :test do
  gem 'climate_control'
  gem 'rspec-default_http_header'
  gem 'rspec-rails', group: :development
  gem 'webmock', require: 'webmock/rspec'
end
