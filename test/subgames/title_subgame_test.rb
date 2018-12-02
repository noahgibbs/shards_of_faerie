require 'test_helper'

class TitleSubgameTest < SubgameTestCase
  tests PlayerActionChannel

  def test_new_account
    handle_basic_subscription user: users(:newbie)

    assert_equal TitleSubgameConnection, subscription.current_subgame_connection.class

    sgs = SubgameState.where(:character_id => nil, :user_id => users(:newbie).id, :subgame_id => subgames(:title).id).first
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

  def test_thickening_in_green_first_char
    handle_basic_subscription user: users(:newbie)

    assert_equal 0, users(:newbie).characters.size
    perform :receive, gameaction: "thickening_in_green"

    assert_equal EntwinedSubgameConnection, subscription.current_subgame_connection.class
    assert_equal "green_emergence", subscription.current_subgame_connection.twining_name
    assert_equal 1, Character.where(:user_id => users(:newbie).id).count
  end

  def test_thickening_in_green_later_char
    handle_basic_subscription user: users(:newish)

    assert_equal 1, users(:newish).characters.size
    perform :receive, gameaction: "thickening_in_green"

    assert_equal EntwinedSubgameConnection, subscription.current_subgame_connection.class
    assert_equal "green_emergence", subscription.current_subgame_connection.twining_name
    assert_equal 2, Character.where(:user_id => users(:newish).id).count
  end

  # This character ("blob") has no current subgame ID, but has a default subgame ID (which is required.)
  def test_reach_out_unset
    handle_basic_subscription user: users(:newish)

    assert_equal 1, users(:newish).characters.size
    assert_equal TitleSubgameConnection, subscription.current_subgame_connection.class
    perform :receive, gameaction: "reach_out_one", charname: "blob"
    assert_equal EntwinedSubgameConnection, subscription.current_subgame_connection.class

    # No new character should be created
    assert_equal 1, Character.where(:user_id => users(:newish).id).count
  end

  def test_reach_out_emergence
    handle_basic_subscription user: users(:lessnewish)

    assert_equal 2, users(:lessnewish).characters.size
    assert_equal TitleSubgameConnection, subscription.current_subgame_connection.class
    perform :receive, gameaction: "reach_out_one", charname: "blorg"
    assert_equal EntwinedSubgameConnection, subscription.current_subgame_connection.class

    # No new character should be created
    assert_equal 2, Character.where(:user_id => users(:lessnewish).id).count
  end
end
