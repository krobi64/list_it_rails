class CreateSessions < ActiveRecord::Migration[6.0]
  def change
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.index :session_id, unique: true
      t.text :data
      t.timestamps
      t.index :updated_at
    end
  end
end
