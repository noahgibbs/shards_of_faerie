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

    # TODO later: have some kind of not-always-reloaded version

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
  end

  # * Preprocess with Erubis in an execution environment documented below
  # * [[Links]] as well as [[Links->target]] and [[target<-Links]] are processed
  # * Render with the RedCarpet Markdown parser
  def self.process_passage_content(content)
    @renderer ||= Redcarpet::Render::HTML.new
    @markdown_parser ||= Redcarpet::Markdown.new(@renderer)

    template = Erubis::Eruby.new(content)
    content = template.evaluate

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
    move_to_passage @twining[:startnode]
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

  def move_to_passage(passage_name)
    @passage = @twining[:passages][passage_name]
    processed_content = self.class.process_passage_content @passage[:content]
    @transitions = processed_content.scan(/data-target='(.*?)'/).flatten
    replace_html(".client-area", processed_content)
  end
end
