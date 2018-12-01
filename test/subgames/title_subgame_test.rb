require 'test_helper'

class TitleSubgameTest < SubgameTestCase
  tests PlayerActionChannel

  def test_new_account
    handle_basic_subscription user: users(:newbie)

    assert_equal TitleSubgameConnection, subscription.current_subgame_connection.class

    sgs = SubgameState.where(:character_id => nil, :user_id => users(:newbie).id, :subgame_id => TITLE_SUBGAME_ID).first
    assert sgs, "No title-screen subgame state created for new blank user!"

    # We should have exactly one message which replaces the game text. It should allow the thickening_in_green action,
    # but not allow reaching out to an existing character - there isn't one.
    assert transmissions.detect { |msg|
      msg["action"] == "replace" &&
      msg["content"]["thickening_in_green"] &&
      !msg["content"]["reach_out"]
    }, "Can't find websocket message with title screen text!"
    assert_equal 1, transmissions.select { |msg| msg["action"] == "replace" }.size
  end

  def test_one_char
    handle_basic_subscription user: users(:newish)

    assert_equal TitleSubgameConnection, subscription.current_subgame_connection.class

    # We should have exactly one message which replaces the game text. It should allow the thickening_in_green action,
    # and allow reaching out to an existing character.
    assert transmissions.detect { |msg|
      msg["action"] == "replace" &&
      msg["content"]["thickening_in_green"] &&
      msg["content"]["reach_out"]
    }, "Can't find websocket message with title screen text!"
    assert_equal 1, transmissions.select { |msg| msg["action"] == "replace" }.size
  end

  def test_multi_char
    handle_basic_subscription user: users(:lessnewish)

    assert_equal TitleSubgameConnection, subscription.current_subgame_connection.class

    # We should have exactly one message which replaces the game text. It should allow the thickening_in_green action,
    # and allow reaching out to an existing character.
    assert transmissions.detect { |msg|
      msg["action"] == "replace" &&
      msg["content"]["thickening_in_green"] &&
      msg["content"]["reach_out"] &&
      msg["content"]["awarenesses"]
    }, "Can't find websocket message with title screen text!"
    assert_equal 1, transmissions.select { |msg| msg["action"] == "replace" }.size
  end
end
