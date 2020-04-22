class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false
      t.index :email, unique: true
      t.string :crypted_password
      t.string :password_salt, null: false
      t.string :persistence_token, null: false
      t.index :persistence_token, unique: true
      t.string :perishable_token
      t.index :perishable_token, unique: true
      t.string :single_access_token, :null => false

      t.integer :login_count, default: 0, null: false
      t.integer :failed_login_count, default: 0, null: false
      t.datetime :last_request_at
      t.datetime :current_login_at
      t.datetime :last_login_at
      t.string :current_login_ip
      t.string :last_login_ip

      t.boolean :active, default: false
      t.boolean :approved, default: false
      t.boolean :confirmed, default: false

      t.timestamps
    end
  end
end
