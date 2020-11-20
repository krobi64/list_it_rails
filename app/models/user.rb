class User < ApplicationRecord

  has_secure_password

  has_many :lists
  has_and_belongs_to_many :shared_lists, class_name: 'List', association_foreign_key: :list_id

  # Reference https://medium.com/@Timothy_Fell/how-to-set-password-requirements-in-rails-d9081926923b
  PASSWORD_REQUIREMENTS = /\A
    (?=.{8,})
    (?=.*\d)
    (?=.*[a-z])
    (?=.*[A-Z])
    (?=.*[[:^alnum:]])
  /x

  validate :email_value

  validates :email,
            uniqueness: { case_sensitive: false, message: 'Email already in use' }

  validates :password,
            confirmation: true,
            format: {
                with: PASSWORD_REQUIREMENTS,
                message: 'is missing one or more requirements.'
            }

  def all_lists
    lists + shared_lists
  end

  private

    def email_value
      errors.add(:email, 'Invalid email address') unless Truemail.valid?(email, with: :regex)
    end

end
