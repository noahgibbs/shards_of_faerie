# EventingSubgame is a simple actions-and-time subgame, mostly conducted in Javascript,
# similar to games like Universal Paperclips in basic feel.

class EventingSubgameConnection < SubgameConnection
  attr_reader :eventing_name
  attr_reader :eventing

  def initialize(channel, eventing_name)
    super(channel)
    @eventing_name = eventing_name
    #@eventing = self.class.eventing_by_name eventing_name
    replace_html_with_template(".client-area", "eventing/index")

    run_js "window.simpleEventing = new SimpleGameModel(0.0); window.EventingSubgame.activate(window.simpleEventing);"
  end

  def receive(data)
    #if data["passageaction"]
    #else
      Rails.logger.warn "Eventing: received unexpected action: #{data.inspect}"
    #end
  end

  def self.eventing_by_name(name)
    @eventings ||= {}

    filename = File.join(Rails.root / "app/gamedata/eventings/#{name}.rb")

    if !@eventings[name.to_s] || (File.mtime(filename) > @eventings[name.to_s][:load_time])
      @eventings.delete(name.to_s)
      load_eventing_file(filename)
    end

    @eventings[name.to_s]
  end

  def self.load_eventing_file(filename)
    @eventings ||= {}

    context = EventingContext.new
    context.instance_eval File.read(filename), filename

    eventing_name = context.eventing_name

    raise("eventing with empty name for file #{filename.inspect}!") if eventing_name.nil? || eventing_name.empty?
    raise("eventing with duplicate name for file #{filename.inspect}!") if @eventings[eventing_name.to_s]

    # TODO: You know, like, everything

    @eventings[eventing_name.to_s] = {
      filename: filename,
      name: eventing_name.to_s,
      load_time: Time.now,
      # TODO: add data members
    }
    nil
  end

  # For DSL-based formats, you want a file loading context
  class EventingContext
  end
end
