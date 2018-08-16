
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
          [new_sections_directive,
           new_interpolations_directive('test'),
           new_interpolations_directive('extra'),
           new_interpolations_directive('content'),
           new_flags_directive],
          config.comment_type)
    else
      Mumukit::Directives::NullPipeline
    end
  end

  def new_interpolations_directive(key)
    Mumukit::Directives::Interpolations.new(key)
  end

  def new_sections_directive
    Mumukit::Directives::Sections.new nest_sections: Mumukit.config.multifile_support
  end

  def new_flags_directive
    Mumukit::Directives::Flags.new
  end

  def self.default_config
    @default_config
  end

  def self.configure_defaults
    @default_config ||= OpenStruct.new
    yield @default_config
  end
end
