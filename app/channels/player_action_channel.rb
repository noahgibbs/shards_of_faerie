# A channel object will be instantiated when the cable consumer
# becomes a subscriber, and then lives until the consumer
# disconnects. This may be seconds, minutes, hours, or even days.
# - https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html

# The PlayerActionChannel is for things the player does that affect the
# state of the game world.

# Specifically, it dispatches to various sub-game objects for
# different game modes.

# Bookmarks:
#
# * https://github.com/palkan/action-cable-testing#channels-testing
# * https://guides.rubyonrails.org/action_cable_overview.html
# *

class PlayerActionChannel < ApplicationCable::Channel
  # Called after successful subscription
  def subscribed
    unless @current_subgame_connection.nil?
      raise "Somehow subscribed initially with non-nil subgame instance var! Dying!"
    end

    stream_for current_user
    #stream_from "player_actions_#{current_user.id}"
    # reject unless current_user.can_access?(@room)

    # TODO: do this intelligently, not "pick first"
    if current_user.characters.size > 0
      set_current_character current_user.characters.first.id
    end
    set_subgame_connection TitleSubgameConnection.new(self)
  end

  def set_subgame_connection(csc)
    @current_subgame_connection = csc
  end

  def set_current_character(char_id)
    @current_char_id = char_id
    @current_char = nil
  end

  def current_character
    return @current_char if @current_char
    raise "No character ID set!" unless @current_char_id
    @current_char ||= Character.where(id: @current_char_id).first
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
