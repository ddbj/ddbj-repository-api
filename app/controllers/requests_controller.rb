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
      head :conflict
    else
      request.canceled!

      head :no_content
    end
  end

  private

  def requests
    current_user.requests.includes(:submission)
  end
end
