require "erubis"

class SubgameConnection
  def initialize(channel)
    @channel = channel
  end

  # Override this in subclasses
  def receive(data)
  end

  def send(data)
    @channel.send_single(data)
  end

  def replace_html(elt_selector, new_content)
    send(action: "replace", selector: elt_selector, content: new_content)
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

require "title"
require "entwined"
