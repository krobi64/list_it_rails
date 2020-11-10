class CreateAccount
  prepend SimpleCommand
  include ActiveModel::Validations

  def initialize(email, password, password_confirmation, first_name = nil, last_name = nil)
    @email = email
    @password = password
    @password_confirmation = password_confirmation
    @first_name = first_name
    @last_name = last_name
  end

  def call
    user = User.create(email: email, password: password, password_confirmation: password_confirmation, first_name: first_name, last_name: last_name)
    if user.persisted?
      return JsonWebToken.encode(id: user.id)
    else
      errors.add(:base, :failure)
      user.errors.messages.each do |attr, message|
        Array.wrap(message).each do |m|
          errors.add(attr, m)
        end
      end
    end
    nil
  end

  private

  attr_accessor :email, :password, :password_confirmation, :first_name, :last_name

end
