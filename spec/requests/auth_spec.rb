require 'rails_helper'

RSpec.describe 'authentication', type: :request do
  let(:oidc_client) { spy(:oidc_client) }

  let(:oidc_config) {
    double(:oidc_config, **{
      issuer: 'ISSUER',
      jwks:   'JWKS'
    })
  }

  let(:id_token) {
    spy(:id_token, **{
      sub: 'SUB',

      raw_attributes: {
        preferred_username: 'alice'
      }
    })
  }

  around do |example|
    ClimateControl.modify OIDC_CLIENT_ID: 'CLIENT_ID', &example
  end

  before do
    allow_any_instance_of(AuthsController).to receive(:oidc_client) { oidc_client }
    allow_any_instance_of(AuthsController).to receive(:decode_id_token_jwt) { id_token }

    allow(AuthsController).to receive(:oidc_config) { oidc_config }
    allow(OpenIDConnect::ResponseObject::IdToken).to receive(:decode) { id_token }
    allow(oidc_client).to receive(:authorization_uri) { 'http://example.com/auth/authorization' }
  end

  describe 'login -> callback' do
    let(:access_token) {
      double(:access_token, id_token: 'ID_TOKEN_JWT')
    }

    before do
      allow_any_instance_of(AuthsController).to receive(:generate_state) { 'STATE' }
      allow_any_instance_of(AuthsController).to receive(:generate_code_verifier) { 'CODE_VERIFIER' }
      allow_any_instance_of(AuthsController).to receive(:calculate_code_challenge).with('CODE_VERIFIER') { 'CODE_CHALLENGE' }

      allow(oidc_client).to receive(:access_token!) { access_token }
    end

    example do
      get '/auth/login'

      expect(response).to redirect_to('http://example.com/auth/authorization')

      expect(oidc_client).to have_received(:authorization_uri).with(
        scope:                 %i(openid),
        state:                 'STATE',
        code_challenge:        'CODE_CHALLENGE',
        code_challenge_method: 'S256'
      )

      get '/auth/callback', params: {
        state: 'STATE',
        code:  'CODE'
      }

      expect(response).to have_http_status(:ok)

      user = DwayUser.find_by!(sub: 'SUB')

      expect(user).to have_attributes(
        uid:     'alice',
        api_key: match(/\Addbj_repository_[[:alnum:]]+\z/)
      )

      expect(response.body).to include("Your API key is: #{user.api_key}")

      expect(oidc_client).to have_received(:authorization_code=).with('CODE')
      expect(oidc_client).to have_received(:access_token!).with(code_verifier: 'CODE_VERIFIER')
      expect(OpenIDConnect::ResponseObject::IdToken).to have_received(:decode).with('ID_TOKEN_JWT', 'JWKS')

      expect(id_token).to have_received(:verify!).with(
        issuer:    'ISSUER',
        client_id: 'CLIENT_ID'
      )
    end
  end

  describe 'login by id token' do
    example do
      post '/api/auth/login_by_id_token', **{
        params:  'ID_TOKEN_JWT',
        headers: {'Content-Type': 'applicaiton/jwt'}
      }

      expect(response).to have_http_status(:ok)

      user = DwayUser.find_by!(sub: 'SUB')

      expect(response.parsed_body.deep_symbolize_keys).to eq(
        api_key: user.api_key
      )

      expect(OpenIDConnect::ResponseObject::IdToken).to have_received(:decode).with('ID_TOKEN_JWT', 'JWKS')

      expect(id_token).to have_received(:verify!).with(
        issuer:    'ISSUER',
        client_id: 'CLIENT_ID'
      )
    end
  end
end
