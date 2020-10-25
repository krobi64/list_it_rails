class CreateListUser < ActiveRecord::Migration[6.0]
  def change
    create_join_table :lists, :users
  end
end
