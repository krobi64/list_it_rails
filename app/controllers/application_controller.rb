class ApplicationController < ActionController::API

  before_action :authenticate_request
  attr_reader :current_user

  def route_not_found
    render json: message(:error, 'Not found' ), status: :not_found
  end


  private

  def message(status, payload)
    { status: status, payload: payload}
  end

  def authenticate_request
    authorization = AuthorizeApiRequest.call(request.headers)
    if authorization.success?
      @current_user = authorization.result
    else
      render json: message(:error, authorization.errors), status: :unauthorized
    end
  end
end
