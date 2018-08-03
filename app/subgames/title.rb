class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    replace_html(".client-area", "Text from the server <button class='action-button' click-action='entwined'>Entwined</button>")
  end

  def receive(data)
    if data["action"] == "entwined"
      STDERR.puts "Received entwined action"
    end
  end
end
