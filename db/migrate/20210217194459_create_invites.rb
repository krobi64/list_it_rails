class CreateInvites < ActiveRecord::Migration[6.1]
  def change
    create_table :invites do |t|
      t.string :email
      t.integer :list_id
      t.integer :sender_id
      t.integer :recipient_id, null: true
      t.integer :status, default: 1
      t.string :token
      t.timestamps
    end
  end
end
