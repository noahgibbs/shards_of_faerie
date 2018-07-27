class PlayerActionChannel < ApplicationCable::Channel
  # Called after successful subscription
  def subscribed
    # stream_from "some_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
