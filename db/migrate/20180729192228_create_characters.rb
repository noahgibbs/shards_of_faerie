class CreateCharacters < ActiveRecord::Migration[5.2]
  def change
    create_table :characters do |t|
      t.string :name, limit: 50
      t.json :appearance
      t.integer :user_id

      t.timestamps
    end
    add_index :characters, :name, unique: true
    add_index :characters, :user_id
  end
end