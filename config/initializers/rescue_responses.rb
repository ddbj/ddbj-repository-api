Rails.application.config.action_dispatch.rescue_responses = {
  'Requests::FilesController::NotFound'   => :not_found,
  'Submission::FilesController::NotFound' => :not_found
}
