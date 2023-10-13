class RequestsController < ApplicationController
  def show
    request    = dway_user.requests.find(params[:id])
    submission = request.submission

    render json: {
      status: request.status,
      result: request.result,

      submission: submission ? {
        id: submission.id
      } : nil
    }
  end
end
