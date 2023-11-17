dbs = DB.map { _1[:id].downcase }

Rails.application.routes.draw do
  resource :auth, only: %i() do
    get :login
    get :callback
  end

  scope :api do
    resource :auth, only: %i() do
      post :login_by_id_token
    end

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
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
