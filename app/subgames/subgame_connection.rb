require "erubis"

class SubgameConnection
  def initialize(channel)
    @channel = channel
  end

  def self.subgame_id_by_name(name)
    id = Subgame.subgame_id_for_name(name)
    raise "Querying nonexistent Subgame ID for name #{name.inspect}! Fix code or run rails db:seed!" unless id
    id
  end

  # Override this in subclasses
  def receive(data)
  end

  def data_send(data)
    @channel.send_single(data)
  end

  def replace_html(elt_selector, new_content)
    data_send(action: "replace", selector: elt_selector, content: new_content)
  end

  def replace_html_with_template(elt_selector, template_name, locals: {})
    unless template_name["."]
      template_name += ".html.erb"
    end
    filename = File.join("app/views", template_name)
    tmpl = Erubis::Eruby.new(File.read filename)
    replace_html(elt_selector, tmpl.evaluate(locals))
  end
end
