class AuthsController < ApplicationController
  skip_before_action :authenticate

  def self.oidc_config
    @oidc_config ||= OpenIDConnect::Discovery::Provider::Config.discover!(ENV.fetch('OIDC_ISSUER_URL'))
  end

  def login
    state         = session[:state]         = SecureRandom.urlsafe_base64(32)
    nonce         = session[:nonce]         = SecureRandom.urlsafe_base64(32)
    code_verifier = session[:code_verifier] = SecureRandom.urlsafe_base64(32)

    code_challenge = Base64.urlsafe_encode64(
      OpenSSL::Digest::SHA256.digest(code_verifier),
      padding: false
    )

    redirect_to oidc_client.authorization_uri(
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

    unless state == params.require(:state)
      render plain: 'Error: state mismatch', status: :bad_request

      return
    end

    oidc_client.authorization_code = params.require(:code)

    access_token = oidc_client.access_token!(code_verifier:)
    user         = upsert_user_by_id_token(access_token.id_token, nonce:)

    render plain: <<~TEXT
      Logged in as #{user.uid}.
      Your API token is: #{user.api_token}
    TEXT
  rescue Rack::OAuth2::Client::Error => e
    render plain: "Error: #{e.message}", status: :bad_request
  end

  def login_by_id_token
    user = upsert_user_by_id_token(params.require(:id_token), nonce: params.require(:nonce))

    render json: {
      api_token: user.api_token
    }
  end

  private

  def upsert_user_by_id_token(id_token, nonce:)
    id_token = OpenIDConnect::ResponseObject::IdToken.decode(id_token, self.class.oidc_config.jwks)

    id_token.verify!(
      issuer:    self.class.oidc_config.issuer,
      client_id: ENV.fetch('OIDC_CLIENT_ID'),
      nonce:
    )

    id_token.raw_attributes => {preferred_username:}

    DwayUser.find_or_initialize_by(sub: id_token.sub).tap {|user|
      user.update! uid: preferred_username
    }
  end

  def oidc_client
    @oidc_client ||= OpenIDConnect::Client.new(
      identifier:             ENV.fetch('OIDC_CLIENT_ID'),
      redirect_uri:           callback_auth_url,
      jwks_uri:               self.class.oidc_config.jwks_uri,
      authorization_endpoint: self.class.oidc_config.authorization_endpoint,
      token_endpoint:         self.class.oidc_config.token_endpoint,
      userinfo_endpoint:      self.class.oidc_config.userinfo_endpoint
    )
  end
end
