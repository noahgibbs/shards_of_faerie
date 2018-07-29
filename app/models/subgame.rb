class Subgame < ApplicationRecord
  def self.subgame_id_for_name(name)
    sg = Subgame.where(:name => name)[0].id
  end
end
