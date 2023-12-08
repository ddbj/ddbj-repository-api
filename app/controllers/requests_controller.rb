class RequestsController < ApplicationController
  def index
    @requests = requests.order(:id)
  end

  def show
    @request = requests.find(params[:id])
  end

  private

  def requests
    dway_user.requests.where(created_at: 1.month.ago..).includes(:submission)
  end
end
