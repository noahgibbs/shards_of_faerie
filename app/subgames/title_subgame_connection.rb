class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    @@title_subgame_id ||= Subgame.subgame_id_for_name("Title")

    characters = Character.where(:user_id => channel.current_user.id).all
    if characters.size == 0
      @character = Character.create(:user_id => channel.current_user.id, :name => "A slight intensity in the Green", :appearance => { "body" => "none" } )
      characters = [ @character ]
    else
      @character = characters.first  # For now, just pick one
    end

    if characters.size == 1 && @character.appearance["body"] == "none"
      # Only one character, and that one is basically *just* autocreated
      replace_html_with_template(".client-area", "title/no_chars")
    elsif characters.size == 1
      # At least one character is already basically in existence
      replace_html_with_tempalte(".client-area", "title/one_char")
    else
      # Multiple characters in existence
      replace_html_with_template(".client-area", "title/multiple_chars", locals: { characters: characters })
    end
  end

  def receive(data)
    if data["gameaction"] == "thickening_in_green"
      @channel.set_subgame_connection EntwinedSubgameConnection.new(@channel, "green_emergence")
    elsif data["gameaction"] == "reaching_out"
      @channel.set_subgame_connection ActivitySubgameConnection.new(@channel, @character)
    elsif data["gameaction"] == "reach_out_one"
      char_name = data["charname"]
      character = Character.where(:user_id => @channel.current_user.id, :name => char_name).first
      @channel.set_subgame_connection ActivitySubgameConnection.new(@channel, selected_character)
    else
      STDERR.puts "Received unexpected gameaction: #{data.inspect} (this may be because of multiple clicks)"
    end
  end
end
