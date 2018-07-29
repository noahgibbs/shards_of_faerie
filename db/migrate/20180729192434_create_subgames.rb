class CreateSubgames < ActiveRecord::Migration[5.2]
  def change
    create_table :subgames do |t|
      t.string :name, limit: 30

      t.timestamps
    end
    add_index :subgames, :name, unique: true
  end
end
