class User < ApplicationRecord

  has_secure_password

  has_and_belongs_to_many :lists

  validates :email,
            format: {
                with: URI::MailTo::EMAIL_REGEXP,
                message: "should look like an email address."
            },
            length: { maximum: 100 },
            uniqueness: {
                case_sensitive: false,
            }

  validates :password,
            confirmation: true,
            length: {
                minimum: 8,
            }
  validates :password_confirmation,
            length: {
                minimum: 8,
            }

end
