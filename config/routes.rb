dbs = DB.map { _1[:id].downcase }

Rails.application.routes.draw do
  resource :auth, only: %i() do
    get :login
    get :callback
  end

  scope :api do
    resource :api_key, path: 'api-key', only: %i(show) do
      post :regenerate
    end

    resource :auth, only: %i() do
      post :login_by_access_token
    end

    resource :me, only: %i(show)

    namespace :submissions do
      scope ':db' do
        resource :via_file, only: %i(create), path: 'via-file', constraints: {db: Regexp.union(*dbs)}
      end
    end

    namespace :validations do
      scope ':db' do
        resource :via_file, only: %i(create), path: 'via-file', constraints: {db: Regexp.union(*dbs)}
      end
    end

    resources :requests, only: %i(show)

    resources :submissions, only: %i(index show) do
      resources :files, only: %i(show), path: 'files/:object_id', param: :path, constraints: {path: /.+/}
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
