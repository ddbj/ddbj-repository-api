RSpec.configure do |config|
  config.around do |example|
    Dir.mktmpdir do |repository_dir|
      Dir.mktmpdir do |user_home_dir|
        env = {
          REPOSITORY_DIR: repository_dir,
          USER_HOME_DIR:  user_home_dir,
          VALIDATOR_URL:  'http://validator.example.com/api',
        }

        ClimateControl.modify env, &example
      end
    end
  end
end
