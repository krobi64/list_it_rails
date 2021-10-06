class ItemsController < ApplicationController
  before_action :current_list
  before_action :current_item, only: [:show, :update, :toggle, :destroy]

  def index
    result = params[:uc] == '1' ? current_list.unchecked_items : current_list.items
    render json: message(:success, result)
  end

  def create
    item = current_list.items.create(item_params)
    if item.persisted?
      head :created
    else
      render json: message(:error, item.errors), status: :bad_request
    end
  end

  def show
    render json: message(:success, current_item)
  end

  private
    def current_list
      @current_list ||= current_user.all_lists.where(id: params[:list_id]).first
      @current_list || raise(ListItError::ListNotFound.new)
    end

    def current_item
      @current_item ||= current_list.items.find(params[:id])
    end
    def item_params
      params.require(:item).permit(:name)
    end
end
