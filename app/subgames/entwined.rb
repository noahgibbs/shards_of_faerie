# This class exists for the Entwined subgame format, based pretty
# closely on Twine's Snowman format.

# Snowman preprocesses markdown in the story passages. It does that
# via a [series of steps documented in its
# README](https://github.com/klembot/snowman). Entwined does something
# similar but different, and omits the div- and span-processing that
# Snowman changes between different versions.

# * Preprocess with Erubis in an execution environment documented below
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

class EntwinedSubgameConnection < SubgameConnection
  def self.twining_by_name(name)
    @twinings ||= {}
    @twinings[name.to_s]
  end

  def self.load_twining_file(filename)
    @twinings ||= {}

    doc = File.open(filename, "r") { |f| Nokogiri::XML(f) }
    storydata = doc.css("tw-storydata")
    twining_name = storydata.attribute("name").value
    story_startnode = storydata.attribute("startnode").value

    raise("Twining with empty name for file #{filename.inspect}!") if twining_name.nil? || twining_name.empty?
    raise("Twining with duplicate name for file #{filename.inspect}!") if @twinings[twining_name.to_s]

    styles = doc.css("tw-storydata style").map { |node| node.content }
    scripts = doc.css("tw-storydata script").map { |node| node.content }

    passages = {}
    doc.css("tw-storydata tw-passagedata").map do |node|
      passage_content = preprocess_passage_content node.content
      transitions = passage_content.scan(/data-target='(.*?)'/).flatten
      passage = {
        pid: node.attribute("pid").value,
        name: node.attribute("name").value,
        tags: node.attribute("tags").value,
        content: passage_content,
        transitions: transitions,
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
    }
  end

  # * Preprocess with Erubis in an execution environment documented below
  # * [[Links]] as well as [[Links->target]] and [[target<-Links]] are processed
  # * Render with the RedCarpet Markdown parser
  def self.preprocess_passage_content(content)
    @renderer ||= Redcarpet::Render::HTML.new
    @markdown_parser ||= Redcarpet::Markdown.new(@renderer)

    template = Erubis::Eruby.new(content)
    content = template.evaluate

    # Regexp is from Snowman, Ruby code is obviously not
    content.gsub(/\[\[(.*?)\]\]/) do |target|
      display = target

      rightIndex = target.index("->")
      if rightIndex.nil?
        leftIndex = target.index("<-")
        unless leftIndex.nil?
          display = target[(leftIndex+1)..-1]
          target = target[0..leftIndex]
        end
      else
        display = target[0...rightIndex]
        target = target[(rightIndex+1)..-1]
      end

      # Link to "target" passage, with text "display"
      "<a class='passage-link' data-target='#{target}'>#{display}</a>"

      # Snowman uses: '<a href="javascript:void(0)" data-passage="' + _.escape(target) + '">' + display + '</a>';
    end

    # Now process with RedCarpet
    @markdown_parser.render(content)
  end

  def initialize
  end

  def receive(data)
  end
end
