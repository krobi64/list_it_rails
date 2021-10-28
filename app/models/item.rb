class Item < ApplicationRecord
  belongs_to :list

  ITEM_STATE = {
    unchecked: 0,
    checked: 1
  }

  before_create :set_order
  after_create :set_token

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
      "order" => order,
      "sort_token" => token
    }
  end

  private

    # sort_order should be 0-based list
    def set_order
      self.order = (list.items.maximum(:order) || -1) + 1
    end

    def set_token
      self.token = ItemVerifier.instance.generate("Item#{id}")
      save!
    end

end
