class ListsController < ApplicationController


  before_action :current_list, only: [:show, :update, :delete, :share]

  def index
    render json: {status: :success, payload: @current_user.lists.select(:id, :name).all}
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
    if current_list
      render json: message(:success, current_list)
    else
      render json: message(:error, 'Not found') unless current_list
    end
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
    @current_user.lists.find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name)
  end
end
