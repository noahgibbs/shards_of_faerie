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

# Funny thing about this class and autoloading? Turns out that Rails
# autoloading will get rid of the class object. That means that
# caching like this on the class object will go away with each code
# reload. Surprise! So it's important to reload when necessary, rather
# than caching in advance in, say, an initializer. It's an interesting
# enforcement of best practices!

class EntwinedSubgameConnection < SubgameConnection
  def self.twining_by_name(name)
    @twinings ||= {}

    filename = File.join(Rails.root / "app/gamedata/twinings/#{name}.rb")

    if !@twinings[name.to_s] || (File.mtime(filename) > @twinings[name.to_s][:load_time])
      @twinings.delete(name.to_s)
      load_twining_rb_file(filename)
    end

    @twinings[name.to_s]
  end

  class TwiningStyleContext
    attr_reader :got_content
    def content(content)
      @got_content = content
    end
  end

  class TwiningScriptContext
    attr_reader :got_content
    def content(content)
      @got_content = content
    end
  end

  class TwiningPassageContext
    attr_reader :got_pid
    attr_reader :got_tags
    attr_reader :got_content

    def initialize
      @got_tags = []
    end

    def pid(pid)
      @got_pid = pid
    end

    def tags(tags)
      @got_tags = tags
    end

    def content(content)
      @got_content = content
    end
  end

  class TwiningContext
    attr_reader :twining_name
    attr_reader :startnode
    attr_reader :idstring
    attr_reader :styles
    attr_reader :scripts
    attr_reader :passages

    def initialize
      @styles = []
      @scripts = []
      @passages = []
      @names = {}
      @passage_num = 1
    end

    def name(name)
      @twining_name = name
    end

    def start(name)
      @startnode = name
    end

    def id(name)
      @idstring = name
    end

    def style(content = nil, &block)
      if block_given?
        context = TwiningStyleContext.new
        context.instance_eval(&block)
        @styles << context.got_content
      else
        @styles << { content: content }
      end
    end

    def script(content = nil, &block)
      if block_given?
        context = TwiningStyleContext.new
        context.instance_eval(&block)
        @scripts << context.got_content
      else
        @scripts << { content: content }
      end
    end

    def passage(name, &block)
      raise("Passage with duplicate name: #{name.inspect}!") if @names[name]
      @names[name] = true

      context = TwiningPassageContext.new
      context.instance_eval &block
      pid = context.got_pid || @passage_num
      raise("Passage has no content block!") if context.got_content.nil?
      @passages << {
        pid: pid.to_s,
        name: name.to_s,
        tags: context.got_tags,
        content: context.got_content
      }
      raise("Passage with duplicate pid: #{context.got_pid.inspect}!") if @names[pid]
      @names[pid] = true

      @passage_num += 1
    end
  end

  def self.load_twining_rb_file(filename)
    @twinings ||= {}

    context = TwiningContext.new
    context.instance_eval File.read(filename), filename

    twining_name = context.twining_name

    raise("Twining with empty name for file #{filename.inspect}!") if twining_name.nil? || twining_name.empty?
    raise("Twining with duplicate name for file #{filename.inspect}!") if @twinings[twining_name.to_s]

    passages = {}
    context.passages.each do |passage|
      passages[passage[:pid]] = passage
      passages[passage[:name]] = passage
    end
    @twinings[twining_name.to_s] = {
      filename: filename,
      name: twining_name.to_s,
      startnode: context.startnode.to_s,
      styles: context.styles,
      scripts: context.scripts,
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

  attr_reader :twining_name
  attr_reader :passage

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
        Rails.logger.warn "Entwined: received unexpected passage action: #{data.inspect}"
      end
    else
      Rails.logger.warn "Entwined: received unexpected action: #{data.inspect}"
    end
  end

  protected

  def context_object
    @context_object ||= EntwinedContext.new(twining_name: @twining_name, channel: @channel, user: @channel.current_user, character: @channel.current_character)
  end

  def move_to_passage(passage_name)
    raise("No passage named #{passage_name.inspect}!") unless @twining[:passages][passage_name]
    @passage = @twining[:passages][passage_name]
    context_object.set_passage(passage_name)
    processed_content = self.class.process_passage_content @passage[:content], passage_name, @context_object
    @transitions = processed_content.scan(/data-target='(.*?)'/).flatten
    replace_html(".client-area", processed_content)
  end
end

class EntwinedContext
  attr_reader :twining_name
  attr_reader :channel
  attr_reader :user
  attr_reader :character
  attr_reader :subgame_state

  def initialize(twining_name:, channel:, user:, character:)
    @@entwined_subgame_id ||= Subgame.where(name: "Entwined").first.id

    @twining_name = twining_name
    @channel = channel
    @user = user
    @character = character
    @subgame_state = SubgameState.where(user_id: user.id, character_id: character.id, subgame_id: @@entwined_subgame_id).first_or_create { |s| s.state = {} }
  end

  def set_passage(passage)
    @passage = passage
    @subgame_state.state["passage"] = passage
    @subgame_state.save!
  end

  # State object for this character
  def s
    @state_wrapper ||= EntwinedWrapperObject.new(@subgame_state.state, @subgame_state)
  end

  def appearance
    @appearance_wrapper ||= EntwinedWrapperObject.new(@character.appearance, @character)
  end
end

class EntwinedWrapperObject
  def initialize(context, obj_to_save)
    @context = context
    @obj_to_save = obj_to_save
  end

  def [](key)
    @context[key]
  end

  def []=(key, value)
    @context[key] = value
    @obj_to_save.save!
  end
end
