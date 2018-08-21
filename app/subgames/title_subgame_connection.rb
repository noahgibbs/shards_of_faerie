class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    replace_html_with_template(".client-area", "title/index")
  end

  def receive(data)
    if data["gameaction"] == "entwined"
      STDERR.puts "Received entwined action"
      @channel.set_subgame_connection EntwinedSubgameConnection.new(@channel, "green_emergence")
    else
      STDERR.puts "Received non-entwined action [1]: #{data.inspect} (this may be because of multiple clicks)"
    end
  end
end
