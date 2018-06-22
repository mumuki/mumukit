module Mumukit::Runner::Pipeline
  def directives_pipeline
    @pipeline ||= new_directives_pipeline
  end

  def new_directives_pipeline
    if config.preprocessor_enabled
      Mumukit::Directives::Pipeline.new(
          [Mumukit::Directives::Sections.new,
           Mumukit::Directives::Interpolations.new('test'),
           Mumukit::Directives::Interpolations.new('extra'),
           Mumukit::Directives::Interpolations.new('content'),
           Mumukit::Directives::Flags.new],
          config.comment_type)
    else
      Mumukit::Directives::NullPipeline
    end
  end
end
