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
    @current_user = AuthorizeApiRequest.call(request.headers).result
    render json: {status: :error, payload: 'Not Authorized'}, status: 401 unless @current_user
  end
end
