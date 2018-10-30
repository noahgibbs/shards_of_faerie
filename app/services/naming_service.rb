require "demiurge/name_generator"
# The NameGenerator defines a method #generate_from_name(name) to create one string.
# It defines a method #names which returns all token names.

class NamingService
  SERVICES = {
    faery_names: [ "app/gamedata/namegen/fae_names.namegen" ]
  }
  def self.generator_from_filenames(filenames)
    gen = Demiurge::NameGenerator.new
    filenames.each { |fn| gen.load_rules_from_andor_string(File.read fn) }
    gen
  end

  def self.subservice(name)
    name = name.to_sym
    @services ||= {}
    return @services[name] if @services[name]
    raise "No such subservice (#{name.inspect})!" unless SERVICES[name]
    @services[name] = generator_from_filenames(SERVICES[name])
  end
end
