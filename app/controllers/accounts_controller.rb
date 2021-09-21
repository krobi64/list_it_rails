class AccountsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create, :new]

  def index
  end

  def new
    @token = params[:token]
  end

  def create
    command = CreateAccount.call(user_params[:email], user_params[:password], user_params[:password_confirmation], user_params[:first_name], user_params[:last_name])

    if command.success?
      process_invite if params[:token].present?
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
    def process_invite
      user = User.find(email: user_params[:email])
      AcceptInvite.new(user, params[:token]).call
    end

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name)
    end
end
