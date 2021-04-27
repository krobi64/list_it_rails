class ListsController < ApplicationController

  before_action :current_list, only: [ :update, :delete ]

  def index
    render json: message(:success, @current_user.all_lists)
  end

  def create
    list = @current_user.all_lists.create(list_params.merge(user: current_user))
    if list.persisted?
      head :created
    else
      render json: message(:error, list.errors), status: :bad_request
    end
  end

  def show
    current_list = current_user.all_lists.find(params[:id])
    render json: message(:success, current_list)
  end

  def update
    if current_list.update(list_params)
      head(:no_content)
    else
      render json: message(:error, current_list.errors), status: :bad_request
    end
  end

  def destroy
    current_list.destroy
    head :no_content
  end

  def share
    user = User.where(email: params[:email]).first
    invite = SendInvite.new(params[:email], current_list, current_user, user).call
    user.lists << current_list unless user.nil?
    if invite.successful?
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
end
