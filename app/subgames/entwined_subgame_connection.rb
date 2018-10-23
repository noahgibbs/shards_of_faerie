# This class exists for the Entwined subgame format, inspired
# by Twine's Snowman format.

# Snowman preprocesses markdown in the story passages. It does that
# via a [series of steps documented in its
# README](https://github.com/klembot/snowman). Entwined does something
# similar but different, and omits the div- and span-processing that
# Snowman changes between different versions.

# * Process with Erubis in an execution environment documented below
# * (Not implemented)Remove comments, from hash to end of line
# * [[Links]] as well as [[Links->target]] and [[target<-Links]] are processed
# * Render with the RedCarpet Markdown parser

# The double-square-bracket links are converted to JavaScript links
# generating JavaScript actions.

# ## Erubis Execution Environment

# (...)

# Links:
#
# * https://twinery.org
# * https://github.com/klembot/snowman
# * https://github.com/vmg/redcarpet

# Funny thing about this class and autoloading? Turns out that
# autoloading will get rid of the class object. That means that
# caching like this on the class object will go away with each code
# reload. Surprise! So it's important to reload when necessary, rather
# than caching in advance in, say, an initializer. It's an interesting
# enforcement of best practices!

class EntwinedSubgameConnection < SubgameConnection
  def self.twining_by_name(name)
    @twinings ||= {}

    filename = File.join(Rails.root / "app/gamedata/twinings/#{name}.twining")
    if !@twinings[name.to_s] || (File.mtime(filename) > @twinings[name.to_s][:load_time])
      @twinings.delete(name.to_s)
      load_twining_file(filename)
    end

    @twinings[name.to_s]
  end

  def self.load_twining_file(filename)
    @twinings ||= {}

    doc = File.open(filename, "r") { |f| Nokogiri::XML(f) { |config| config } }
    storydata = doc.css("tw-storydata")
    twining_name = storydata.attribute("name").value
    story_startnode = storydata.attribute("startnode").value

    raise("Twining with empty name for file #{filename.inspect}!") if twining_name.nil? || twining_name.empty?
    raise("Twining with duplicate name for file #{filename.inspect}!") if @twinings[twining_name.to_s]

    styles = doc.css("tw-storydata style").map { |node| node.content }
    scripts = doc.css("tw-storydata script").map { |node| node.content }

    passages = {}
    doc.css("tw-storydata tw-passagedata").map do |node|
      passage_content = node.content
      passage = {
        pid: node.attribute("pid").value,
        name: node.attribute("name").value,
        tags: node.attribute("tags").value,
        content: passage_content,
      }
      passages[passage[:pid]] = passage
      passages[passage[:name]] = passage
    end
    @twinings[twining_name.to_s] = {
      filename: filename,
      name: twining_name.to_s,
      startnode: story_startnode,
      styles: styles,
      scripts: scripts,
      passages: passages,
      load_time: Time.now,
    }
    nil
  end

  # * Preprocess with Erubis in an execution environment documented below
  # * [[Links]] as well as [[Links->target]] and [[target<-Links]] are processed
  # * Render with the RedCarpet Markdown parser
  def self.process_passage_content(content, content_name, context_object)
    @renderer ||= Redcarpet::Render::HTML.new
    @markdown_parser ||= Redcarpet::Markdown.new(@renderer)

    template = Erubis::Eruby.new(content, :filename => content_name)
    content = template.evaluate context_object

    # Regexp is from Snowman, Ruby code is obviously not
    content.gsub!(/\[\[(.*?)\]\]/) do |full|
      target = display = $1

      rightIndex = target.index("|")
      unless rightIndex.nil?
        display = target[0...rightIndex]
        target = target[(rightIndex+1)..-1]
      end

      # Link to "target" passage, with text "display"
      "<a class='passage-link' data-target='#{target}' href='#'>#{display}</a>"

      # Snowman uses: '<a href="javascript:void(0)" data-passage="' + _.escape(target) + '">' + display + '</a>';
    end

    # Now process with RedCarpet
    @markdown_parser.render(content)
  end

  def initialize(channel, twining_name)
    super(channel)
    @twining_name = twining_name
    @twining = EntwinedSubgameConnection.twining_by_name twining_name
    current_passage = context_object.subgame_state.state["passage"] || @twining[:startnode]
    move_to_passage current_passage
  end

  def receive(data)
    if data["passageaction"]
      if @transitions.include?(data["passageaction"])
        move_to_passage data["passageaction"]
      else
        STDERR.puts "Entwined: received unexpected passage action: #{data.inspect}"
      end
    else
      STDERR.puts "Entwined: received unexpected action: #{data.inspect}"
    end
  end

  protected

  def context_object
    @context_object ||= EntwinedContextObject.new(twining_name: @twining_name, channel: @channel, user_id: @channel.current_user.id, character_id: @channel.current_character.id)
  end

  def move_to_passage(passage_name)
    raise("No such passage!") unless @twining[:passages][passage_name]
    @passage = @twining[:passages][passage_name]
    context_object.set_passage(passage_name)
    processed_content = self.class.process_passage_content @passage[:content], passage_name, @context_object
    @transitions = processed_content.scan(/data-target='(.*?)'/).flatten
    replace_html(".client-area", processed_content)
  end
end

class EntwinedContextObject
  attr_reader :twining_name
  attr_reader :channel
  attr_reader :user_id
  attr_reader :character_id
  attr_reader :subgame_state

  def initialize(twining_name:, channel:, user_id:, character_id:)
    @@entwined_subgame_id = Subgame.where(name: "Entwined").first.id

    @twining_name = twining_name
    @channel = channel
    @user_id = user_id
    @character_id = character_id
    @subgame_state = SubgameState.where(character: character_id, subgame_id: @@entwined_subgame_id).first_or_create { |s| s.state = {} }
  end

  def set_passage(passage)
    @passage = passage
    @subgame_state.state["passage"] = passage
    @subgame_state.save!
  end

  # State object for this Entwined passage(s)
  def s
    @wrapper ||= EntwinedWrapperObject.new(self)
  end
end

class EntwinedWrapperObject
  def initialize(context)
    @context = context
  end

  def [](key)
    @context.subgame_state.state[key]
  end

  def []=(key, value)
    @context.subgame_state.state[key] = value
    @context.subgame_state.save!
  end
end
