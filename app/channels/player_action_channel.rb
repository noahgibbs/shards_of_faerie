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
  attr_reader :current_subgame_connection
  attr_reader :current_character

  def initialize(*args)
    super
    @@null_subgame_id = TitleSubgameConnection.subgame_id_by_name("None")
  end

  # Called after successful subscription
  def subscribed
    unless @current_subgame_connection.nil?
      raise "Somehow subscribed initially with non-nil subgame instance var! Dying!"
    end

    # Permit broadcasting to the current user for things like to-user chat messages
    stream_for current_user
    #stream_from "player_actions_#{current_user.id}"
    # reject unless current_user.can_access?(@room)

    @subgame_data = SubgameState.where(:character_id => nil, :user_id => current_user.id, :subgame_id => @@null_subgame_id).first_or_create { |d| d.state = {} }

    characters = current_user.characters
    if characters.size == 0
      @current_character = nil
    elsif @subgame_data.state["last_character_id"]
      # Don't need switch_to_character since we're pre-switched
      @current_character = Character.where(:id => @subgame_data.state["last_character_id"]).first
    end

    # If no previous (correct) character, just pick one
    if characters.size > 0 && !@character
      switch_to_character characters.first
    end

    set_subgame_connection TitleSubgameConnection.new(self)
  end

  def set_subgame_connection(csc)
    @current_subgame_connection = csc
  end

  def switch_to_character(char)
    return if @subgame_data.state["last_character_id"] == char.id

    @current_character = char
    @subgame_data.state["last_character_id"] = char.id
    @subgame_data.save!
  end

  def send_single(data)
    #self.class.broadcast_to current_user, data
    transmit data
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
    #stop_all_streams
  end

  def receive(data)
    @current_subgame_connection.receive(data)
  end
end
