class ApplicationController < ActionController::API
  private

  def dway_user
    uid = request.headers['X-Dway-User-ID']

    DwayUser.find_or_create_by!(uid:)
  end
end
