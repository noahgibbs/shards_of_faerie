class CreateSubgameStates < ActiveRecord::Migration[5.2]
  def change
    create_table :subgame_states do |t|
      t.integer :character_id
      t.integer :subgame_id
      t.json :state

      t.timestamps
    end
    add_index :subgame_states, :character_id, unique: true
    add_index :subgame_states, :subgame_id, unique: true
  end
end
