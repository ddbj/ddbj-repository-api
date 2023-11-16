class AuthsController < ApplicationController
  skip_before_action :authenticate

  def login
    state         = session[:state]         = SecureRandom.urlsafe_base64(32)
    nonce         = session[:nonce]         = SecureRandom.urlsafe_base64(32)
    code_verifier = session[:code_verifier] = SecureRandom.urlsafe_base64(32)

    code_challenge = Base64.urlsafe_encode64(
      OpenSSL::Digest::SHA256.digest(code_verifier),
      padding: false
    )

    redirect_to client.authorization_uri(
      scope:                 %i(openid),
      state:                 ,
      nonce:                 ,
      code_challenge:        ,
      code_challenge_method: 'S256'
    ), allow_other_host: true
  end

  def callback
    state         = session.delete(:state)
    nonce         = session.delete(:nonce)
    code_verifier = session.delete(:code_verifier)

    if state.nil? || state != params.require(:state)
      render plain: 'Error: The state parameter is missing or does not match.', status: :bad_request

      return
    end

    client.authorization_code = params.require(:code)

    access_token = client.access_token!(code_verifier:)
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
  rescue Rack::OAuth2::Client::Error => e
    render plain: "Error: #{e.message}", status: :bad_request
  end

  private

  def client
    @client ||= OpenIDConnect::Client.new(
      identifier:             ENV.fetch('OIDC_CLIENT_ID'),
      redirect_uri:           callback_auth_url,
      jwks_uri:               OIDC_CONFIG.jwks_uri,
      authorization_endpoint: OIDC_CONFIG.authorization_endpoint,
      token_endpoint:         OIDC_CONFIG.token_endpoint,
      userinfo_endpoint:      OIDC_CONFIG.userinfo_endpoint
    )
  end
end
