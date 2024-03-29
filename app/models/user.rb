class User < ApplicationRecord

  has_secure_password

  has_many :lists
  has_and_belongs_to_many :all_lists, class_name: 'List', association_foreign_key: :list_id, dependent: :nullify
  has_many :invites, foreign_key: 'recipient_id'
  has_many :sent_invites, class_name: 'Invite', foreign_key: 'sender_id'

  # Reference https://medium.com/@Timothy_Fell/how-to-set-password-requirements-in-rails-d9081926923b
  PASSWORD_REQUIREMENTS = /\A
    (?=.{8,})
    (?=.*\d)
    (?=.*[a-z])
    (?=.*[A-Z])
    (?=.*[[:^alnum:]])
  /x

  validates_with EmailValidator

  validates :email,
            uniqueness: { case_sensitive: false, message: DUPLICATE_EMAIL }

  validates :password,
            confirmation: true,
            format: {
                with: PASSWORD_REQUIREMENTS,
                message: INVALID_PASSWORD
            }

  def invite(invite_id)
    invitation = invites.where(id: invite_id, recipient_id: id).or(sent_invites.where(id: invite_id, sender_id: id)).first
    invitation || raise(ListItError::InvitationNotFound.new)
  end

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def list(list_id)
    all_lists.where(list_id: list_id, user_id: id).first
  end

  def all_invites
    sent_invites + invites
  end

  def shared_lists
    all_lists.where.not(user_id: self.id)
  end
end
