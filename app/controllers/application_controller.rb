class ApplicationController < ActionController::API

  before_action :authenticate_request
  attr_reader :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :missing_parameter

  def route_not_found
    render json: message(:error, I18n.t('routes.errors.not_found') ), status: :not_found
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

    def model_string
      controller_name.classify.underscore
    end

    def not_found
      render json: message(:error, I18n.t("activerecord.models.#{model_string}.errors.not_found")), status: :not_found
    end

    def missing_parameter
      render json: message(:error, I18n.t("actioncontroller.errors.#{model_string}.invalid_parameters")), status: :bad_request
    end

end
