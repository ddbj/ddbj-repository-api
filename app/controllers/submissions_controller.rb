class SubmissionsController < ApplicationController
  def index
    @submissions = submissions.order(:id)
  end

  def show
    @submission = submissions.find(params[:id].delete_prefix('X-'))
  end

  private

  def submissions
    current_user.submissions.includes(request: {objs: :file_blob})
  end
end
