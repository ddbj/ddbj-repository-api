class RequestsController < ApplicationController
  def show
    request = dway_user.requests.find(params[:id])

    render json: {
      status: request.status,
      result: request.result
    }
  end

  def status
    request = dway_user.requests.find(params[:request_id])

    render json: {
      status: request.status
    }
  end
end
