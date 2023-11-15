dbs = DB.map { _1[:id].downcase }

Rails.application.routes.draw do
  resource :auth, only: %i() do
    get :initiate
    get :callback
  end

  scope :api do
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
