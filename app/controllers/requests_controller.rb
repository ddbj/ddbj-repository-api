class RequestsController < ApplicationController
  def show
    @request = dway_user.requests.find(params[:id])
  end
end
