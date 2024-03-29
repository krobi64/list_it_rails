class AuthenticateUser
  prepend SimpleCommand

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    JsonWebToken.encode(id: user.id) if user
  end

  private

  attr_accessor :email, :password

  def user
    user = User.where(email: email).first
    return user if user && user.authenticate(password)

    errors.add :user_authentication, INVALID_CREDENTIALS
    nil
  end
end
