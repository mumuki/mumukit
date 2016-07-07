class Mumukit::Runner
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def configure
    @config ||= self.class.default_config.clone
    yield @config
  end

  def config
    @config
  end

  def prefix
    name.camelize
  end

  def self.default_config
    @default_config
  end

  def self.configure_defaults
    @default_config ||= OpenStruct.new
    yield @default_config
  end
end