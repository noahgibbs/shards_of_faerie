class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    replace_html_with_template(".client-area", "title/index")
  end

  def receive(data)
    if data["action"] == "entwined"
      STDERR.puts "Received entwined action"
    else
      STDERR.puts "Received non-entwine action: #{data.inspect}"
    end
  end
end
