class InvitesController < ApplicationController
  before_action :current_invite, only: [:show, :destroy, :resend]

  def index
    invites = Invite.all_invites(current_user)
    render json: message(:success, invites)
  end

  def show
    render json: message(:success, current_invite)
  end

  def create
    list = current_user.lists.where(id: invite_params[:list_id]).first
    raise ListItError::ListNotFound.new(I18n.t('activerecord.models.list.errors.not_found')) if list.nil?
    user = User.where(email: invite_params[:email]).first
    invite = SendInvite.new(invite_params[:email], list, current_user, user).call
    if invite.successful?
      head :created
    else
      render json: message(:error, invite.errors), status: :bad_request
    end
  end

  def destroy
    current_invite.destroy if current_invite.sender == current_user
    head :no_content
  end

  def resend

  end

  def accept
    token = params[:token]
    accept = AcceptInvite.new(current_user, token).call
    if accept.successful?
      render json: message(:success, accept.result)
    else
      render json: message(:error, accept.errors)
    end
  end

  private

    def invite_params
      params.require(:invite).permit(:email, :list_id)
    end

    def current_invite
      @current_invite ||= current_user.invite(params[:id])
    end
end
