ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

NULL_SUBGAME_ID = Subgame.where(:name => "None").first.id
TITLE_SUBGAME_ID = Subgame.where(:name => "Title").first.id
ENTWINED_SUBGAME_ID = Subgame.where(:name => "Entwined").first.id

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

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionCable::Channel::TestCase
  # To check broadcast content, this seems to be the correct way.
  # There are assertions, but they seem to only be for the *number*
  # of broadcasts on a channel, not the content of those broadcasts.
  # And broadcasts do *not* seem to populate the transmissions array,
  # even if there is a correct subscription.
  def server_broadcasts_for(broadcast)
    ActionCable.server.pubsub.broadcasts(broadcast).map { |s| JSON.load(s) }
  end
end

class SubgameTestCase < ActionCable::Channel::TestCase
  def handle_basic_subscription(chars: [], id: USER_STUB_FAKE_ID)
    @cur_user = PACUserStub.new(chars, id: id)
    stub_connection current_user: @cur_user

    subscribe
    assert subscription.confirmed?, "Subscription failed: not confirmed!"
  end
end
