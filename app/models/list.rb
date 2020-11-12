class List < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :shared_users, class_name: 'User', association_foreign_key: :user_id
  has_many :items

  validates :name, presence: true
end
