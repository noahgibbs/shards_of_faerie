class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_top"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    ActionCable.server.broadcast("chat_top", { sent_by: current_user.email, body: data["body"] } )
  end
end
