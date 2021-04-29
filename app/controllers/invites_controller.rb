class InvitesController < ApplicationController
  before_action :current_invite, only: [:show, :destroy, :resend]
  skip_before_action :authenticate_request, only: :accept

  def index
    invites = Invite.all_invites(current_user)
    render json: message(:success, invites)
  end

  def show
    render json: message(:success, current_invite)
  end

  def create
    list = current_user.lists.find(invite_params[:list_id])
    user = User.where(email: invite_params[:email]).first
    invite = SendInvite.new(invite_params[:email], list, current_user, user).call
    if invite.successful?
      render json: message(:success, invite.result), status: :accepted
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

  private

    def invite_params
      params.require(:invite).permit(:email, :list_id)
    end

    def current_invite
      @current_invite ||= current_user.invite(params[:id])
    end

end
