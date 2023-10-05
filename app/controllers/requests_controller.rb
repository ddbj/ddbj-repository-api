class RequestsController < ApplicationController
  def status
    request = dway_user.requests.find(params[:request_id])

    render json: {
      status: request.status
    }
  end
end
