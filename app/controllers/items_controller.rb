class ItemsController < ApplicationController
  before_action :current_list
  before_action :current_item, only: [:show, :update, :toggle, :destroy]
  rescue_from ListItError::InvalidListMembers, with: :invalid_items

  def index
    result = params[:uc] == '1' ? current_list.unchecked_items : current_list.items
    render json: message(:success, result)
  end

  def create
    item = current_list.items.create(item_params)
    if item.persisted?
      render json: message(:success, item), status: :created
    else
      render json: message(:error, item.errors), status: :bad_request
    end
  end

  def show
    render json: message(:success, current_item)
  end

  def update
    current_item.update(name: item_params[:name])
    if current_item.valid?
      head :no_content
    else
      render json: message(:error, current_item.errors), status: :bad_request
    end
  end

  def reorder
    items = params[:order]
    ResortListItems.new(current_list, items).call
    render json: message(:success, current_list.items)
  end

  def toggle
    current_item.toggle_state(params[:state])
    head :no_content
  end

  def destroy
    current_item.destroy
    head :no_content
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

    def invalid_items
      render json: message(:error, INVALID_ITEMS), status: :bad_request
    end
end
