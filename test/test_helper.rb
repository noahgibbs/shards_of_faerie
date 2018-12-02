ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

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
  def handle_basic_subscription(user:)
    stub_connection current_user: user

    subscribe
    assert subscription.confirmed?, "Subscription failed: not confirmed!"
  end
end
