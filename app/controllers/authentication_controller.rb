class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    command = AuthenticateUser.call(params[:email], params[:password])

    if command.success?
      render json: message(:success, command.result)
    else
      render json: message(:error, command.errors), status: :unauthorized
    end
  end
end
