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
      passage = {
        pid: node.attribute("pid").value,
        name: node.attribute("name").value,
        tags: node.attribute("tags").value,
        content: node.content,
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

  def initialize
  end

  def receive(data)
  end
end
