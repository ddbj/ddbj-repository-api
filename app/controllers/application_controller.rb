class ApplicationController < ActionController::API
  before_action :authenticate

  private

  def authenticate
    head :unauthorized unless dway_user
  end

  def dway_user
    return nil unless uid = request.headers['X-Dway-User-ID']

    DwayUser.find_or_create_by!(uid:)
  end
end
