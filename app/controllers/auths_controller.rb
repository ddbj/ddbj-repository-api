class AuthsController < ApplicationController
  skip_before_action :authenticate

  def login
    state = session[:state] = SecureRandom.urlsafe_base64
    nonce = session[:nonce] = SecureRandom.urlsafe_base64

    redirect_to client.authorization_uri(
      scope: %i(openid),
      state: ,
      nonce:
    ), allow_other_host: true
  end

  def callback
    state = session.delete(:state)
    nonce = session.delete(:nonce)

    if state.nil? || state != params[:state]
      render plain: 'Error: The state parameter is missing or does not match.', status: :bad_request

      return
    end

    client.authorization_code = params[:code]

    access_token = client.access_token!
    id_token     = OpenIDConnect::ResponseObject::IdToken.decode(access_token.id_token, OIDC_CONFIG.jwks)

    id_token.verify!(
      issuer:    OIDC_CONFIG.issuer,
      client_id: ENV.fetch('OIDC_CLIENT_ID'),
      nonce:
    )

    userinfo = access_token.userinfo!
    user     = DwayUser.find_or_initialize_by(sub: userinfo.sub)

    user.update! uid: userinfo.preferred_username

    render plain: user.api_token
  end

  private

  def client
    @client ||= OpenIDConnect::Client.new(
      identifier:             ENV.fetch('OIDC_CLIENT_ID'),
      secret:                 ENV.fetch('OIDC_CLIENT_SECRET'),
      redirect_uri:           callback_auth_url,
      jwks_uri:               OIDC_CONFIG.jwks_uri,
      authorization_endpoint: OIDC_CONFIG.authorization_endpoint,
      token_endpoint:         OIDC_CONFIG.token_endpoint,
      userinfo_endpoint:      OIDC_CONFIG.userinfo_endpoint
    )
  end
end
