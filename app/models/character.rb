class Character < ApplicationRecord
  belongs_to :user
  has_many :subgame_states
end
