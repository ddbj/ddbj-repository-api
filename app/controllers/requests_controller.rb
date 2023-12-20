class RequestsController < ApplicationController
  def index
    @requests = requests.order(:id)
  end

  def show
    @request = requests.find(params[:id])
  end

  def destroy
    request = requests.find(params[:id])

    if request.finished? || request.canceled?
      render json: {
        error: "Request already #{request.status}."
      }, status: :conflict
    else
      request.canceled!

      render json: {
        message: 'Request canceled successfully.'
      }
    end
  end

  private

  def requests
    current_user.requests.includes(:submission)
  end
end
