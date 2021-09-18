class InvitesController < ApplicationController
  skip_before_action :authenticate_request, only: [:accept]
  before_action :redirect_accept, only: [:accept]
  before_action :current_invite, only: [:show]
  before_action :owner_invite, only: [:destroy, :resend]

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
    command = WithdrawInvite.new(current_user, owner_invite).call
    if command.success?
      head :no_content
    else
      render json: message(:error, command.errors), status: :not_found
    end
  end

  # TODO: Add mailer
  def resend
    owner_invite
    render json: message(:success, I18n.t('activemodel.success.models.send_invite'))
  end

  def accept
    token = params[:token]
    accept = AcceptInvite.new(current_user, token).call
    if accept.successful?
      render json: message(:success, { list: accept.result})
    else
      render json: message(:error, accept.errors), status: :bad_request
    end
  end

  private
    def redirect_accept
      authorization = AuthorizeApiRequest.call(request.headers)
      if authorization.success?
        @current_user = authorization.result
      else
        redirect_to new_account_path(token: params[:token])
      end
    end

    def invite_params
      params.require(:invite).permit(:email, :list_id)
    end

    def owner_invite
      @owner_invite ||= current_user.sent_invites.find(params[:id])
    end

    def current_invite
      @current_invite ||= current_user.invite(params[:id])
    end
end
