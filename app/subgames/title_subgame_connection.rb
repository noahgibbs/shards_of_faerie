class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    @@title_subgame_id ||= Subgame.subgame_id_for_name("Title")
    @user = channel.current_user
    @subgame_data = SubgameState.where(:character_id => nil, :user_id => @user.id, :subgame_id => @@title_subgame_id).first_or_create { |d| d.state = {} }

    characters = Character.where(:user_id => @user.id).all
    if characters.size == 0
      @character = Character.create(:user_id => @user.id, :name => "A slight intensity in the Green", :appearance => { "body" => "none" } )
      @character.save!
      characters = [ @character ]
      @subgame_data.state["last_character_id"] = @character.id
      @subgame_data.save!
    elsif @subgame_data.state["last_character_id"]
      @character = Character.where(:id => @subgame_data.state["last_character_id"]).first
    end

    # If no previous (correct) character, just pick one
    unless @character
      @character = characters.first
      @subgame_data.state["last_character_id"] = @character.id
      @subgame_data.save!
    end

    if characters.size == 1 && @character.appearance["body"] == "none"
      # Only one autocreated character - effectively zero
      replace_html_with_template(".client-area", "title/no_chars")
    elsif characters.size == 1
      # At least one character is already around and set up
      replace_html_with_template(".client-area", "title/one_char")
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
