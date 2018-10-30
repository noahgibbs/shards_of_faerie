class CreateCharacters < ActiveRecord::Migration[5.2]
  def change
    create_table :characters do |t|
      t.string :name, limit: 50, null: false
      t.json :appearance
      t.integer :user_id, null: false

      t.timestamps
    end
    add_index :characters, [:name, :user_id], unique: true
  end
end
