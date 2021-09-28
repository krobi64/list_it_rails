class Item < ApplicationRecord
  belongs_to :list

  ITEM_STATE = {
    unchecked: 0,
    checked: 1
  }

  before_create :set_order

  validates :name, presence: { message: Messages::ITEM_NAME_BLANK }
  default_scope { order(:order) }

  def toggle_state
    self.state = state ^ 1
    save!
  end

  private

    def set_order
      max_order = Item.where(list: list).maximum('order')
      self.order = (max_order || 0) + 1
    end

end
