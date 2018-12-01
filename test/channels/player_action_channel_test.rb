require 'test_helper'

USER_STUB_FAKE_ID = 337

class PACUserStub
  attr :characters
  attr :id

  def initialize(chars, id: USER_STUB_FAKE_ID)
    @id = id
    @characters = chars
  end

  def to_param  # This is how stream names are generated for models
    @id.to_s
  end
end

class PlayerActionChannelTest < ActionCable::Channel::TestCase
  def setup
    @title_subgame_id = Subgame.where(:name => "Title").first.id
  end

  def test_subscription_and_title_screen
    # A Channel::TestCase will always stub the connection, but we can customize how it does so.
    cur_user = PACUserStub.new([])
    stub_connection current_user: cur_user

    subscribe
    # The "subscription" object is the channel - in this case a PlayerActionChannel.
    # It also quietly includes the ChannelStub methods into the object, which is
    # where things like #confirmed? come from.
    assert subscription.confirmed?, "Subscription failed: not confirmed!"

    # Make sure a new PlayerActionChannel subscribes to the user-specific chat/message channel
    assert streams.include?("player_action:#{USER_STUB_FAKE_ID}"), "PlayerActionChannel must subscribe to user-specific chat stream!"

    assert_equal TitleSubgameConnection, subscription.current_subgame_connection.class

    sgs = SubgameState.where(:character_id => nil, :user_id => USER_STUB_FAKE_ID, :subgame_id => @title_subgame_id).first
    assert sgs, "No title-screen subgame state created for user!"

    # Okay, so "transmissions" doesn't include anything broadcast via FooChannel.broadcast_to, even if we're subbed to it.
    # So I'm not sure how transmissions is supposed to be populated, but it's pretty useless to us here.

    #PlayerActionChannel.broadcast_to cur_user, { fake: :data, goes: :here }  # Nope, doesn't add to transmissions

    # However! We can pull ActionCable.pubsub.broadcasts("broadcast_name") and it'll grab what we want. So I *think*
    # that's what tests need to use.

    # This works (doesn't assert), but also doesn't populate "transmissions"
    #assert_broadcasts("player_action:#{USER_STUB_FAKE_ID}", 1) do
    #  PlayerActionChannel.broadcast_to cur_user, { fake: :data, goes: :here }
    #end

    # This gets the server broadcasts. While transmissions doesn't work, this seems to.
    server_broadcasts = ActionCable.server.pubsub.broadcasts("player_action:#{USER_STUB_FAKE_ID}").map { |s| JSON.load(s) }

    # We should have exactly one message which replaces the game text. It should allow the thickening_in_green action,
    # but not allow reaching out to an existing character - there isn't one.
    assert server_broadcasts.detect { |msg|
      msg["action"] == "replace" &&
      msg["content"]["thickening_in_green"] &&
      !msg["content"]["reach_out"]
    }, "Can't find websocket message with title screen text!"
    assert_equal 1, server_broadcasts.select { |msg| msg["action"] == "replace" }.size
  end

end
