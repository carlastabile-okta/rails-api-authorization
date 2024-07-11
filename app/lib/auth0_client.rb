# frozen_string_literal: true

require 'jwt'
require 'net/http'

class Auth0Client

  # Class members
  Response = Struct.new(:decoded_token, :error)
  Error = Struct.new(:message, :status)
  Token = Struct.new(:token) do
    def validate_roles(roles)
      required_roles = Set.new roles
      token_roles = Set.new token[0][Rails.configuration.auth0.roles]
      required_roles <= token_roles
    end
    def validate_user(current_user)
      current_user.auth0_id == token[0]["sub"]
    end
  end

  # Helper Functions
  def self.domain_url
    "https://#{Rails.configuration.auth0.domain}/"
  end

  def self.decode_token(token, jwks_hash)
    JWT.decode(token, nil, true, {
                 algorithm: 'RS256',
                 iss: domain_url,
                 verify_iss: true,
                 aud: Rails.configuration.auth0.audience.to_s,
                 verify_aud: true,
                 jwks: { keys: jwks_hash[:keys] }
               })
  end

  def self.get_jwks
    jwks_uri = URI("#{domain_url}.well-known/jwks.json")
    Net::HTTP.get_response jwks_uri
  end

  # Token Validation
  def self.validate_token(token)
    jwks_response = get_jwks

    unless jwks_response.is_a? Net::HTTPSuccess
      error = Error.new(message: 'Unable to verify credentials', status: :internal_server_error)
      return Response.new(nil, error)
    end

    jwks_hash = JSON.parse(jwks_response.body).deep_symbolize_keys

    decoded_token = decode_token(token, jwks_hash)

    Response.new(Token.new(decoded_token), nil)
  rescue JWT::VerificationError, JWT::DecodeError => e
    error = Error.new('Bad credentials', :unauthorized)
    Response.new(nil, error)
  end
end