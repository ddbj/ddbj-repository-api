dbs = DB.map { _1[:id].downcase }

Rails.application.routes.draw do
  scope :api do
    post '/:db/submit/via-upload' => 'submit_via_upload#create', constraints: {db: Regexp.union(*dbs)}
    post '/:db/submit/via-user-home-path' => 'submit_via_user_home_path#create', constraints: {db: Regexp.union(*dbs)}

    resources :requests, only: %i(show) do
      get :status
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
