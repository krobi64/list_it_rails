class ItemsController < ApplicationController
  before_action :current_list

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

  private
    def current_list
      @current_list ||= current_user.all_lists.where(id: params[:list_id]).first
      @current_list || raise(ListItError::ListNotFound.new)
    end

    def item_params
      params.require(:item).permit(:name)
    end
end
