class SubmissionsController < ApplicationController
  def index
    @submissions = dway_user.submissions.includes(request: {objs: :file_blob})
  end

  def show
    @submission = dway_user.submissions.find(params[:id].delete_prefix('X-'))
  end
end
