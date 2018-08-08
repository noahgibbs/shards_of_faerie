class Subgame < ApplicationRecord
  has_many :subgame_states  # You wouldn't normally query them this way, but...

  def self.subgame_id_for_name(name)
    sg = Subgame.where(:name => name)[0].id
  end
end
