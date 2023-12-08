class SubmissionsController < ApplicationController
  def index
    @submissions = submissions
  end

  def show
    @submission = submissions.find(params[:id].delete_prefix('X-'))
  end

  private

  def submissions
    dway_user.submissions.includes(request: {objs: :file_blob})
  end
end
