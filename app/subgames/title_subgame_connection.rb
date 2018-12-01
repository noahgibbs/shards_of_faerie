class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    @@title_subgame_id ||= self.class.subgame_id_by_name("Title")
    @@entwined_subgame_id ||= self.class.subgame_id_by_name("Entwined")
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
      replace_html_with_template(".client-area", "title/one_char", locals: { characters: characters })
    else
      # Multiple characters in existence
      replace_html_with_template(".client-area", "title/multiple_chars", locals: { characters: characters })
    end
  end

  def switch_to_character(char)
    return if @subgame_data.state["last_character_id"] == char.id

    @character = char
    @subgame_data.state["last_character_id"] = char.id
    @subgame_data.save!
  end

  def switch_to_current_subgame
    unless @character && @character.id
      raise "Need to select a character before switching to a subgame!"
    end
    if @subgame_data.state["current_subgame_id"]
      case @subgame_data.state["current_subgame_id"]
      when @@entwined_subgame_id
        subgame_connection = EntwinedSubgameConnection.new(@channel, "green_emergence")
      when @@wanderventure_subgame_id
        subgame_connection = WanderventureSubgameConnection.new(@channel, "green_wandering")
      else
        raise "Unknown subgame ID #{@subgame_data.state["current_subgame_id"].inspect}"
      end
      @channel.set_subgame_connection subgame_connection
    else
      # Will need to initialize this
      raise "Can't find an appropriate subgame to switch to!"
    end
  end

  def receive(data)
    if data["gameaction"] == "thickening_in_green"
      @@fae_names ||= NamingService.subservice(:faery_names)
      @character = Character.create(:user_id => @user.id, :name => @@fae_names.generate_from_name("any"), :appearance => { "body" => "none" } )

      # It's possible, but unusual, for this to fail because there already exists a character with that name.
      @character.save!
      switch_to_character @character
      @subgame_data.state["current_subgame_id"] ||= {}
      @subgame_data.state["current_subgame_id"][@character.id] = @@entwined_subgame_id

      @channel.set_subgame_connection EntwinedSubgameConnection.new(@channel, "green_emergence")
    elsif data["gameaction"] == "reach_out_one"
      char_name = data["charname"]
      character = Character.where(:user_id => @channel.current_user.id, :name => char_name).first
      switch_to_character character
      switch_to_current_subgame
    else
      Rails.logger.error("Received unexpected gameaction: #{data.inspect} (this may be because of multiple clicks)")
    end
  end
end
