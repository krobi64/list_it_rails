class AccountsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create, :new]

  def index
  end

  def new
    @token = params[:invite_token]
    render json: message(:success, {invite_token: @token})
  end

  def create
    command = CreateAccount.call(user_params[:email], user_params[:password], user_params[:password_confirmation], user_params[:first_name], user_params[:last_name])

    if command.success?
      if params[:invite_token].present?
        invite = Invite.find_by(token: params[:invite_token])
        list = invite.list
        user = User.find_by(:email, user_params[:email])
        user.shared_lists << list
      end
      render json: message(:success, command.result), status: :created
    else
      render json: message(:error, command.errors), status: :bad_request
    end
  end

  def show
  end

  def update
  end

  def delete
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
    end
end
