class CreateItems < ActiveRecord::Migration[6.0]
  def change
    create_table :items do |t|
      t.references :list, null: false, foreign_key: true
      t.string :name
      t.integer :state

      t.timestamps
    end
  end
end
