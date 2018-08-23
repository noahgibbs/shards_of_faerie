class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    character = Character.where(:user_id => channel.current_user.id)
    characters = character.all
    if characters.size == 0
      @character = Character.create(:user_id => current_user.id, :name => "A slight intensity in the Green", :appearance => { "body" => "none" } )
    else
      @character = character.first  # For now, just pick one
    end

    replace_html_with_template(".client-area", "title/no_chars")
  end

  def receive(data)
    if data["gameaction"] == "thickening_in_green"
      @channel.set_subgame_connection EntwinedSubgameConnection.new(@channel, "green_emergence")
    else
      STDERR.puts "Received unexpected gameaction: #{data.inspect} (this may be because of multiple clicks)"
    end
  end
end
