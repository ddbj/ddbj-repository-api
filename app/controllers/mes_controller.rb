class MesController < ApplicationController
  def show
    render json: {
      uid: dway_user.uid
    }
  end
end
