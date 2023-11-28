class Validations::ViaFilesController < ApplicationController
  include ViaFile

  def create
    request = create_request_from_params(params, dway_user)

    ValidateJob.perform_later request

    render json: {
      request: {
        id:  request.id,
        url: url_for(request)
      }
    }, status: :created
  end
end
