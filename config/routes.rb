dbs = DB.map { _1[:id].downcase }

Rails.application.routes.draw do
  scope :api do
    resources :submissions, only: %i() do
      collection do
        post ':db/via-file' => 'submit_via_file#create', constraints: {db: Regexp.union(*dbs)}
      end
    end

    resources :validations, only: %i() do
      collection do
        post ':db/via-file' => 'validate_via_file#create', constraints: {db: Regexp.union(*dbs)}
      end
    end

    resources :requests, only: %i(show)
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
