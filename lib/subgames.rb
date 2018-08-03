class SubgameConnection
  def initialize(channel)
    @channel = channel
  end

  def receive(data)
  end

  def send(data)
    @channel.send_single(data)
  end

  def replace_html(elt_selector, new_content)
    send(action: "replace", selector: elt_selector, content: new_content)
  end
end

require "title"
require "entwined"
