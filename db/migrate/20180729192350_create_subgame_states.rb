class CreateSubgameStates < ActiveRecord::Migration[5.2]
  def change
    create_table :subgame_states do |t|
      t.integer :character_id  # Can be null in a few cases, like the Title subgame
      t.integer :subgame_id, null: false
      t.json :state

      t.timestamps
    end
    add_index :subgame_states, [:character_id, :subgame_id], unique: true
  end
end
