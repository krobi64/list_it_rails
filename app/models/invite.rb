class Invite < ApplicationRecord
  before_create :generate_token
  before_create :correct_status

  belongs_to :list
  belongs_to :sender, class_name: 'User'
  belongs_to :recipient, class_name: 'User', optional: true

  validates_with EmailValidator
  default_scope { where.not(status: STATUS[:disabled]) }

  STATUS = {
    disabled: 0,
    created: 1,
    emailed: 2,
    accepted: 3,
    error: 4
  }

  def as_json(options = {})
    {
      "id" => id,
      "email" => email,
      "list" => list.as_json,
      "sender" => sender.full_name,
      "recipient" => recipient.try(:full_name),
      "status" => status
    }
  end

  private

    def self.all_invites(user)
      Invite.where(sender_id: user.id).
        or(Invite.where(recipient_id: user.id)).
        or(Invite.where(email: user.email)).
        and(Invite.where(status: [
          STATUS[:created],
          STATUS[:emailed],
          STATUS[:accepted],
          STATUS[:error]])).all
    end

    def generate_token
      self.token = SecureRandom.hex(16)
    end

    def correct_status
      self.status = STATUS[:created]
    end
end
