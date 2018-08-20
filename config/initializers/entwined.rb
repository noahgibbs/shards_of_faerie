# Load in all Twining files from the appropriate directory
Dir["app/gamedata/twinings/*.twining"].each do |twining_file|
  EntwinedSubgameConnection.load_twining_file(twining_file)
end
