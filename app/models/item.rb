class Item < ApplicationRecord
  belongs_to :list

  ITEM_STATE = {
    unchecked: 0,
    checked: 1
  }

  before_create :set_order

  validates :name, presence: { message: Messages::ITEM_NAME_BLANK }
  default_scope { order(:order) }

  def toggle_state(new_state = nil)
    self.state = new_state || state ^ 1
    save!
  end

  def as_json(options = nil)
    {
      "id" => id,
      "name" => name,
      "state" => state,
      "order" => order
    }
  end

  private

    def set_order
      max_order = Item.where(list: list).maximum('order')
      self.order = (max_order || 0) + 1
    end

end
