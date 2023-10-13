dbs = DB.map { _1[:id].downcase }

Rails.application.routes.draw do
  scope :api do
    post '/:db/submit/via-file' => 'submit_via_file#create', constraints: {db: Regexp.union(*dbs)}

    resources :requests, only: %i(show)
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
