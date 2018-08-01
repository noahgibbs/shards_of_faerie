class TitleSubgameConnection < SubgameConnection
  def initialize(channel)
    super

    replace_html(".client-area", "Text from the server")
  end

  def receive(data)
  end
end
