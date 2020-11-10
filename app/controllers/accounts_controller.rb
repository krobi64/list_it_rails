class AccountsController < ApplicationController
  skip_before_action :authenticate_request, only: [:create]

  def index
  end

  def create
    command = CreateAccount.call(user_params[:email], user_params[:password], user_params[:password_confirmation], user_params[:first_name], user_params[:last_name])

    if command.success?
      render json: message(:success, command.result), status: :created
    else
      render json: message(:error, command.errors), status: :conflict
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
