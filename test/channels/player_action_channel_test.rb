require 'test_helper'

class PlayerActionChannelTest < ActionCable::Channel::TestCase
  def test_subscription_and_title_screen
    # A Channel::TestCase will always stub the connection, but we can customize how it does so.
    stub_connection current_user: users(:newbie)

    subscribe
    # The "subscription" object is the channel - in this case a PlayerActionChannel.
    # It also quietly includes the ChannelStub methods into the object, which is
    # where things like #confirmed? come from.
    assert subscription.confirmed?, "Subscription failed: not confirmed!"

    # Make sure a new PlayerActionChannel subscribes to the user-specific chat/message channel
    assert streams.include?("player_action:#{users(:newbie).to_gid_param}"), "PlayerActionChannel must subscribe to user-specific chat stream! (Not: #{streams.inspect})"

    assert_equal TitleSubgameConnection, subscription.current_subgame_connection.class

    sgs = SubgameState.where(:character_id => nil, :user_id => users(:newbie).id, :subgame_id => subgames(:none).id).first
    assert sgs, "No null-subgame state created for user!"

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
