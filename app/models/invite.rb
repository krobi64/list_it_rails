class Invite < ApplicationRecord
  before_create :generate_token
  belongs_to :list
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User', optional: true

  validates_with EmailValidator
  validates :email,
            uniqueness: { case_sensitive: false, message: I18n.t('activerecord.models.invite.errors.email_in_use') }


  private
    def generate_token
      self.token = SecureRandom.hex(16)
    end
end
