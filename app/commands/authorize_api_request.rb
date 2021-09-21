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
    if @decoded_auth_token && (@decoded_auth_token[:exp] < Time.now.to_i)
      errors.add(:token, 'Expired token')
      return nil
    end
    @decoded_auth_token
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
