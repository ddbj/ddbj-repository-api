class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate

  def dway_user
    return @dway_user if defined?(@dway_user)

    @dway_user = authenticate_with_http_token {|token|
      next nil unless user = DwayUser.find_by(api_key: token)

      if user.ddbj_member? && uid = request.headers['X-Dway-User-Id']
        DwayUser.find_by(uid:)
      else
        user
      end
    }
  end

  private

  def authenticate
    render json: {
      error: 'Unauthorized'
    }, status: :unauthorized unless dway_user
  end
end
