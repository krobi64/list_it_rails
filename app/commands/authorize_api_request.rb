class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    user
  end

  private

  attr_reader :headers

  def user
    return unless decoded_auth_token
    @user ||= User.select(:id, :first_name, :last_name, :email).where(id: decoded_auth_token[:id]).first
  end

  def decoded_auth_token
    return unless http_auth_header
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
    @decoded_auth_token || errors.add(:token, INVALID_TOKEN)
  end

  def http_auth_header
    if headers['AUTHORIZATION'].present?
      return headers['AUTHORIZATION'].split(' ').last
    else
      errors.add(:token, MISSING_TOKEN)
    end
    nil
  end
end
