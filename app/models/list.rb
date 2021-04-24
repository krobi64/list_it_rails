class List < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :users
  has_many :items
  has_many :invites

  def shared_users
    users.where.not(user_id: user.id)
  end

  validates :name, presence: true

  default_scope { select(:id, :name, :user_id) }
end
