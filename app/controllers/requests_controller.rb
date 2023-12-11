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
    dway_user.requests.where(created_at: 1.month.ago..).includes(:submission)
  end
end
