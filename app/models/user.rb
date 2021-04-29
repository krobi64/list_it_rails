class User < ApplicationRecord

  has_secure_password

  has_many :lists
  has_and_belongs_to_many :all_lists, class_name: 'List', association_foreign_key: :list_id
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
            uniqueness: { case_sensitive: false, message: 'Email already in use' }

  validates :password,
            confirmation: true,
            format: {
                with: PASSWORD_REQUIREMENTS,
                message: 'is missing one or more requirements.'
            }

  def invite(invite_id)
    invites.where(id: invite_id, recipient_id: id).or(sent_invites.where(id: invite_id, sender_id: id)).first
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
