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

  # To check broadcast content, this seems to be the correct way.
  # There are assertions, but they seem to only be for the *number*
  # of broadcasts on a channel, not the content of those broadcasts.
  # And broadcasts do *not* seem to populate the transmissions array,
  # even if there is a correct subscription.
  def server_broadcasts_for(broadcast)
    ActionCable.server.pubsub.broadcasts(broadcast).map { |s| JSON.load(s) }
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

    # "transmissions" doesn't include anything broadcast via FooChannel.broadcast_to, even if we're subbed to it.
    # For broadcasts we have to use a bit of a hack to check the content of server broadcasts when we want to verify content.

    #server_broadcasts = server_broadcasts_for("player_action:#{USER_STUB_FAKE_ID}")

    # We should have exactly one message which replaces the game text. It should allow the thickening_in_green action,
    # but not allow reaching out to an existing character - there isn't one.
    assert transmissions.detect { |msg|
      msg["action"] == "replace" &&
      msg["content"]["thickening_in_green"] &&
      !msg["content"]["reach_out"]
    }, "Can't find websocket message with title screen text!"
    assert_equal 1, transmissions.select { |msg| msg["action"] == "replace" }.size
  end

end
