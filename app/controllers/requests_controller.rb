class RequestsController < ApplicationController
  def show
    request = dway_user.requests.find(params[:id])

    render json: {
      status:            request.status,
      validity:          request.validity,
      validation_report: request.validation_report,

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
