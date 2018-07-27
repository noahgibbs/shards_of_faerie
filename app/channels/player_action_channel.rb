# A channel object will be instantiated when the cable consumer
# becomes a subscriber, and then lives until the consumer
# disconnects. This may be seconds, minutes, hours, or even days.
# - https://api.rubyonrails.org/classes/ActionCable/Channel/Base.html

# The PlayerActionChannel is for things the player does that affect the
# state of the game world.
class PlayerActionChannel < ApplicationCable::Channel
  # Called after successful subscription
  def subscribed
    # stream_from "some_stream_identifier"
    # reject unless current_user.can_access?(@room)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
