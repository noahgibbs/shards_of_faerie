class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    @@title_subgame_id ||= self.class.subgame_id_by_name("Title")
    @@entwined_subgame_id ||= self.class.subgame_id_by_name("Entwined")
    @user = channel.current_user
    @subgame_data = SubgameState.where(:character_id => nil, :user_id => @user.id, :subgame_id => @@title_subgame_id).first_or_create { |d| d.state = {} }

    characters = @user.characters

    if characters.size == 0
      # No characters
      replace_html_with_template(".client-area", "title/no_chars")
    elsif characters.size == 1
      # At least one character is already around and set up
      replace_html_with_template(".client-area", "title/one_char", locals: { characters: characters })
    else
      # Multiple characters in existence
      replace_html_with_template(".client-area", "title/multiple_chars", locals: { characters: characters, current_character: @channel.current_character })
    end
  end

  def switch_to_current_subgame(character)
    unless character && character.id
      raise "Need to select a character before switching to a subgame!"
    end
    unless @subgame_data
      raise "Need subgame state for TitleSubgameConnection to switch to a new subgame!"
    end

    sgid = nil
    sg_state = @subgame_data.state
    if sg_state["current_subgame_id"] && sg_state["current_subgame_id"][character.id.to_s]
      sgid = sg_state["current_subgame_id"][character.id.to_s]
    elsif sg_state["default_subgame_id"] && sg_state["default_subgame_id"][character.id.to_s]
      sgid = sg_state["default_subgame_id"][character.id.to_s]
    else
      raise "Can't find an appropriate subgame ID to switch to!"
    end

    case sgid
    when @@entwined_subgame_id
      subgame_connection = EntwinedSubgameConnection.new(@channel, "green_emergence")
    when @@wanderventure_subgame_id
      subgame_connection = WanderventureSubgameConnection.new(@channel, "green_wandering")
    else
      raise "Unknown subgame ID #{sgid.inspect}"
    end
    @channel.set_subgame_connection subgame_connection
  end

  def receive(data)
    if data["gameaction"] == "thickening_in_green"
      @@fae_names ||= NamingService.subservice(:faery_names)
      character = Character.create :user_id => @user.id,
                                   :name => @@fae_names.generate_from_name("any"),
                                   :appearance => { "body" => "none" }

      # It's possible, but unusual, for this to fail because there already exists a character with that name.
      character.save!
      @channel.switch_to_character character
      @subgame_data.state["current_subgame_id"] ||= {}
      @subgame_data.state["current_subgame_id"][character.id] = @@entwined_subgame_id
      @subgame_data.state["default_subgame_id"] ||= {}
      @subgame_data.state["default_subgame_id"][character.id] = @@entwined_subgame_id
      @subgame_data.save!

      @channel.set_subgame_connection EntwinedSubgameConnection.new(@channel, "green_emergence")
    elsif data["gameaction"] == "reach_out_one"
      char_name = data["args"]
      character = Character.where(:user_id => @channel.current_user.id, :name => char_name).first
      @channel.switch_to_character character
      switch_to_current_subgame character
    else
      Rails.logger.error("Received unexpected gameaction: #{data.inspect} (this may be because of multiple clicks)")
    end
  end
end
