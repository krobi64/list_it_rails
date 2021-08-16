class AcceptInvite
  prepend SimpleCommand

  def initialize(user, token)
    @user = user
    @token = token
  end

  def call
    invite = Invite.where(token: @token, email: @user.email).first
    if !invite.nil?
      list = invite.list
      @user.all_lists << list
      invite.recipient != @user
      invite.status = Invite::STATUS[:accepted]
      invite.save
      I18n.t('activemodel.success.models.accept_invite')
    else
      errors.add(:token, I18n.t('activemodel.errors.models.accept_invite.attributes.token'))
    end
  end
end
