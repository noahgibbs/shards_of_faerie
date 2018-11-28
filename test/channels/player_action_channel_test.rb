require 'test_helper'

USER_STUB_FAKE_ID = 337

class PACUserStub
  attr :characters
  attr :id

  def initialize(chars, id: USER_STUB_FAKE_ID)
    @id = id
    @characters = chars
  end
end

class PlayerActionChannelTest < ActionCable::Channel::TestCase
  def test_subscribed
    stub_connection current_user: PACUserStub.new([])
    subscribe
    assert subscription.confirmed?, "Subscription failed: not confirmed!"
    assert_equal 1, streams.size
    #assert_equal "player_action:337", streams[0]  # How do user objects become stream names?
  end
end
