# A channel object will be instantiated when the cable consumer
# becomes a subscriber, and then lives until the consumer
# disconnects. This may be seconds, minutes, hours, or even days.
# - https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html

# The PlayerActionChannel is for things the player does that affect the
# state of the game world.

# Specifically, it dispatches to various sub-game objects for
# different game modes.

require "subgames"

class PlayerActionChannel < ApplicationCable::Channel
  attr_reader :character

  # Called after successful subscription
  def subscribed
    unless @current_subgame_connection.nil?
      raise "Somehow subscribed initially with non-nil subgame instance var! Dying!"
    end
    title_subgame_id = Subgame.subgame_id_for_name("Title")
    character = Character.where(:user_id => current_user.id)
    characters = character.all
    if characters.size == 0
      @character = Character.create(:user_id => current_user.id, :name => "A slight intensity in the Green", :appearance => { "body" => "none" } )
    else
      @character = character.first  # For now, just pick one
    end

    # stream_from "some_stream_identifier"
    stream_for current_user
    #stream_from "player_actions_#{current_user.id}"
    # reject unless current_user.can_access?(@room)

    @current_subgame_connection = TitleSubgameConnection.new(self)
  end

  def send_single(data)
    self.class.broadcast_to current_user, data
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    stop_all_streams
  end

  def receive(data)
    @current_subgame_connection.receive(data)
  end
end
