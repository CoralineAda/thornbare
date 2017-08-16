class GameChannel < ApplicationCable::Channel

  def subscribed
    stream_from "game_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def receive(data)
    ActionCable.server.broadcast("game_channel", data)
  end

end
