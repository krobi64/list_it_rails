class Item < ApplicationRecord
  belongs_to :list

  ITEM_STATE = {
    unchecked: 0,
    checked: 1
  }

  validates :name, presence: { message: ITEM_NAME_BLANK }

end
