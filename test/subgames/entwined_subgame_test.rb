require 'test_helper'

class EntwinedSubgameTest < SubgameTestCase
  tests PlayerActionChannel

  def test_new_account
    handle_basic_subscription user: users(:newbie)

    assert_equal 1, transmissions.select { |msg| msg["action"] == "replace" }.size
    transmissions.clear

    perform :receive, gameaction: "thickening_in_green"
    assert_equal EntwinedSubgameConnection, subscription.current_subgame_connection.class
    assert_equal "green_emergence", subscription.current_subgame_connection.twining_name
    assert_equal 1, Character.where(:user_id => users(:newbie).id).count  # Should create a character
    assert_equal "1", subscription.current_subgame_connection.passage[:pid]
  end

  def test_reemergence
    handle_basic_subscription user: users(:emergent)
    transmissions.clear

    perform :receive, gameaction: "reach_out_one", charname: "emer"
    assert_equal EntwinedSubgameConnection, subscription.current_subgame_connection.class
    assert_equal "green_emergence", subscription.current_subgame_connection.twining_name
    assert_equal 1, Character.where(:user_id => users(:emergent).id).count  # Should not create a character
    assert_equal "Who am I?", subscription.current_subgame_connection.passage[:name]
  end

#  #def test_reach_out_emergence
#  #  handle_basic_subscription user: users(:lessnewish)
#
#  #  assert_equal 2, users(:lessnewish).characters.size
#  #  assert_equal TitleSubgameConnection, subscription.current_subgame_connection.class
#  #  perform :receive, gameaction: "reach_out_one", charname: "blorg"
#  #  assert_equal EntwinedSubgameConnection, subscription.current_subgame_connection.class
#
#  #  # No new character should be created
#  #  assert_equal 2, Character.where(:user_id => users(:lessnewish).id).count
  #end
end
