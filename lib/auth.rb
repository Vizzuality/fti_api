# frozen_string_literal: true

require 'jwt'

class Auth
  ALGORITHM = 'HS256'

  def self.issue(payload)
    JWT.encode( payload, auth_secret, ALGORITHM)
  end

  def self.decode(token)
    begin
      JWT.decode(token, auth_secret, true, { algorithm: ALGORITHM }).first
    rescue StandardError
      nil
    end
  end

  def self.auth_secret
    ENV['AUTH_SECRET']
  end
end
