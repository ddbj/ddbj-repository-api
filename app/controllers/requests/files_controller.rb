class Requests::FilesController < ApplicationController
  class NotFound < StandardError; end

  include ActiveStorage::SetCurrent if Rails.env.test?

  def show
    request = current_user.requests.find(params[:request_id])

    raise NotFound unless obj = request.objs.find { _1.path == params[:path] }

    redirect_to obj.file.url, allow_other_host: true
  end
end
