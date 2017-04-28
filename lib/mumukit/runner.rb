
class Mumukit::Runner
  attr_reader :name, :runtime

  def initialize(name)
    @name = name
  end

  def configure
    @config ||= self.class.default_config.clone
    yield @config
  end

  def configure_runtime(config)
    @runtime = Mumukit::Runtime.new(config)
  end

  def config
    @config or raise 'This runner has not being configured yet'
  end

  def prefix
    name.camelize
  end

  def directives_pipeline
    @pipeline ||= new_directives_pipeline
  end

  def new_directives_pipeline
    if config.preprocessor_enabled
      Mumukit::Directives::Pipeline.new(
          [Mumukit::Directives::Sections.new,
           Mumukit::Directives::Interpolations.new('test'),
           Mumukit::Directives::Interpolations.new('extra'),
           Mumukit::Directives::Flags.new],
          config.comment_type)
    else
      Mumukit::Directives::NullPipeline
    end
  end

  def self.default_config
    @default_config
  end

  def self.configure_defaults
    @default_config ||= OpenStruct.new
    yield @default_config
  end
end