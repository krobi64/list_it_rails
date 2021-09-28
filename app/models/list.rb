class List < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :users
  has_many :items
  has_many :invites

  validates :name, presence: { message: I18n.t('activerecord.models.list.errors.name') }

  default_scope { select(:id, :name, :user_id) }

  def unchecked_items
    items.where(state: Item::ITEM_STATE[:unchecked])
  end

  def shared_users
    users.where.not(user_id: user.id)
  end

  def as_json(options = nil)
    {
      "id" => id,
      "created_by" => user.full_name,
      "name" => name
    }
  end
end
