class ListsController < ApplicationController

  before_action :current_list, only: [:show, :update, :delete, :share]

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :missing_parameter

  def index
    render json: message(:success, @current_user.all_lists)
  end

  def create
    list = @current_user.lists.create(list_params)
    if list.persisted?
      head :created
    else
      render json: message(:error, list.errors), status: :conflict
    end
  end

  def show
    render json: message(:success, current_list)
  end

  def update
    if current_list.update(list_params)
      head(:no_content)
    else
      render json: message(:error, current_list.errors), status: :conflict
    end
  end

  def destroy
    current_list.destroy
    head :no_content
  end

  def share
    user = User.where(email: params[:email]).first
    if user
      user.lists << current_list
      head :no_content
    else
      render json: {status: :error, payload: I18n.t('activerecord.models.user.errors.not_found')}, status: :not_found unless user
    end
  end

  private

  def current_list
    @current_list ||= current_user.lists.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name)
  end

  def not_found
    render json: message(:error, I18n.t('activerecord.models.list.errors.not_found')), status: :not_found
  end

  def missing_parameter
    render json: message(:error, I18n.t('actioncontroller.errors.list.invalid_parameters')), status: :conflict
  end
end
