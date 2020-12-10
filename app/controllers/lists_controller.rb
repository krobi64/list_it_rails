class ListsController < ApplicationController


  before_action :current_list, only: [:show, :update, :delete, :share]

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
      render json: {status: :success}
    else
      render json: {status: error, payload: current_list.errors}
    end
  end

  def destroy
    current_list.destroy
    head :no_content
  end

  def share
    user = User.find(params[:user_id])
    render json: {status: :error, payload: 'User not found'}, status: :not_found unless user
    user.lists << current_list
    head :no_content
  end

  private

  def current_list
    begin
      @current_user.lists.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: message(:error, I18n.t('activerecord.models.list.errors.not_found')), status: :not_found
    end
  end

  def list_params
    params.require(:list).permit(:name)
  end
end
