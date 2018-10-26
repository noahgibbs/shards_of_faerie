class Subgame < ApplicationRecord
  has_many :subgame_states  # You wouldn't normally query them this way, but...

  def self.subgame_id_for_name(name)
    sg = Subgame.where(:name => name).first
    unless sg
      STDERR.puts "\n\n\n==== You seem to have forgotten to run rails db:seed! Fix that! ======\n\n\n"
    end
    sg.id
  end
end
