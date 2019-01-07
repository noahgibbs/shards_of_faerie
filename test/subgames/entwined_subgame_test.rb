require 'test_helper'

class EntwinedSubgameTest < SubgameTestCase
  tests PlayerActionChannel

  def test_new_account
    handle_basic_subscription user: users(:newbie)

    assert_equal 1, transmissions.select { |msg| msg["action"] == "replace" }.size

    perform :receive, gameaction: "thickening_in_green"
    assert_equal EntwinedSubgameConnection, subscription.current_subgame_connection.class
    assert_equal "green_emergence", subscription.current_subgame_connection.twining_name
    assert_equal 1, Character.where(:user_id => users(:newbie).id).count  # Should create a character
    assert_equal "1", subscription.current_subgame_connection.passage[:pid]
  end

  def test_reemergence
    handle_basic_subscription user: users(:emergent)

    perform :receive, gameaction: "reach_out_one", args: "emer"
    assert_equal EntwinedSubgameConnection, subscription.current_subgame_connection.class
    assert_equal "green_emergence", subscription.current_subgame_connection.twining_name
    assert_equal 1, Character.where(:user_id => users(:emergent).id).count  # Should not create a character
    assert_equal "Who am I?", subscription.current_subgame_connection.passage[:name]
  end

  def test_formatting
    handle_basic_subscription user: users(:emergent_formatting)
    connection.transmissions.clear

    perform :receive, gameaction: "reach_out_one", args: "emer_form"
    assert_equal "green_emergence", subscription.current_subgame_connection.twining_name
    assert_equal "Formatting Test", subscription.current_subgame_connection.passage[:name]
    assert_equal 1, transmissions.select { |msg| msg["action"] == "replace" }.size
    assert transmissions.detect { |msg|
      msg["action"] == "replace" &&
      msg["content"]["Formatting Test (Content)"] &&
      !msg["content"]["<%"] &&
      msg["content"]["&lt;thingie&gt;"]
    }, "Can't find websocket message with formatting test text!"
  end
end
