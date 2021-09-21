# frozen_string_literal: true

class WithdrawInvite
  prepend SimpleCommand

  def initialize(user, invite)
    @user = user
    @invite = invite
  end

  def call
    return errors.add(:invite, INVITATION_NOT_FOUND) unless invite.sender == user
    if invite.recipient.present?
      invite.recipient.all_lists.delete(invite.list)
    end
    invite.status = Invite::STATUS[:disabled]
    invite.save
  end

  private
    attr_reader :user, :invite

end
