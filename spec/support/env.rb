RSpec.configure do |config|
  config.around do |example|
    env = {
      REPOSITORY_DIR: 'path/to/repository',
      VALIDATOR_URL:  'http://validator.example.com/api',
    }

    ClimateControl.modify env, &example
  end
end
