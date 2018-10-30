class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    @@title_subgame_id ||= Subgame.subgame_id_for_name("Title")
    @user = channel.current_user
    @subgame_data = SubgameState.where(:character_id => nil, :user_id => @user.id, :subgame_id => @@title_subgame_id).first_or_create { |d| d.state = {} }

    characters = Character.where(:user_id => @user.id).all
    if characters.size == 0
      characters = []
    elsif @subgame_data.state["last_character_id"]
      # Don't need switch_to_character since we're pre-switched
      @character = Character.where(:id => @subgame_data.state["last_character_id"]).first
    end

    # If no previous (correct) character, just pick one
    if characters.size > 0 && !@character
      switch_to_character characters.first
    end

    if characters.size == 0
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

  def switch_to_character(char)
    @character = char
    @subgame_data.state["last_character_id"] = char.id
    @subgame_data.save!
  end

  def receive(data)
    if data["gameaction"] == "thickening_in_green"
      # It's possible, but unusual, for this to fail because there already exists a character with that name.
      @@fae_names ||= NamingService.subservice(:faery_names)
      @character = Character.create(:user_id => @user.id, :name => @@fae_names.generate_from_name("any"), :appearance => { "body" => "none" } )
      @character.save!
      switch_to_character @character

      @channel.set_subgame_connection EntwinedSubgameConnection.new(@channel, "green_emergence")
    elsif data["gameaction"] == "reaching_out"
      STDERR.puts "Haven't figured out what to do next here!"
    elsif data["gameaction"] == "reach_out_one"
      char_name = data["charname"]
      character = Character.where(:user_id => @channel.current_user.id, :name => char_name).first
      switch_to_character character
      #@channel.set_subgame_connection ActivitySubgameConnection.new(@channel, selected_character)
      STDERR.puts "Haven't figured out what to do next here!"
    else
      Rails.logger.error("Received unexpected gameaction: #{data.inspect} (this may be because of multiple clicks)")
    end
  end
end
