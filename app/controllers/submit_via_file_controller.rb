class SubmitViaFileController < ApplicationController
  include ViaFile

  def create
    request = create_request_from_params

    SubmitJob.perform_later request

    render json: {
      request: {
        id:  request.id,
        url: url_for(request)
      }
    }, status: :created
  end
end
