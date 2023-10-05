dbs = SubmitViaUploadController::DB_TO_OBJ_IDS_ASSOC.keys

Rails.application.routes.draw do
  scope :api do
    post '/:db/submit/via-upload' => 'submit_via_upload#create', constraints: {db: Regexp.union(*dbs)}

    resources :requests, only: %i() do
      get :status
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check
end
