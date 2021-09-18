class AcceptInvite
  prepend SimpleCommand

  def initialize(user, token)
    @user = user
    @token = token
  end

  def call
    invite = Invite.where(token: token, email: user.email).first
    if invite.present?
      list = invite.list
      user.all_lists << list
      invite.recipient ||= user
      invite.status = Invite::STATUS[:accepted]
      invite.save
      list
    else
      errors.add(:token, INVALID_INVITATION_TOKEN)
    end
  end

  attr_reader :user, :token
end
