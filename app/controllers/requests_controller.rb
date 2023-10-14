class RequestsController < ApplicationController
  def show
    request = dway_user.requests.find(params[:id])

    render json: {
      status: request.status,
      result: request.result,

      submission: request.submission.then {|submission|
        if submission
          {id: submission.public_id}
        else
          nil
        end
      }
    }
  end
end
