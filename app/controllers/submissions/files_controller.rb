class Submissions::FilesController < ApplicationController
  class NotFound < StandardError; end

  include ActiveStorage::SetCurrent if Rails.env.test?

  rescue_from NotFound do
    render json: {
      error: 'Not Found'
    }, status: :not_found
  end

  def show
    submission = dway_user.submissions.find(params[:submission_id].delete_prefix('X-'))

    raise NotFound unless obj = submission.request.objs.find { _1.path == params[:path] }

    redirect_to obj.file.url, allow_other_host: true
  end
end
