class Invite < ApplicationRecord
  before_create :generate_token

  belongs_to :list
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User', optional: true

  validates_with EmailValidator

  private

    def self.all_invites(user)
      Invite.where(sender_id: user.id).or(Invite.where(recipient_id: user.id)).all
    end

    def generate_token
      self.token = SecureRandom.hex(16)
    end
end
