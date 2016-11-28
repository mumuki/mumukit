module Mumukit::RuntimeInfo
  def info
    {
        name: Mumukit.runner_name,
        version: hook_class(:version)::VERSION,
        escualo_base_version: ENV['ESCUALO_BASE_VERSION'],
        escualo_service_version: ENV['ESCUALO_SERVICE_VERSION'],
        mumukit_version: Mumukit::VERSION,
        output_content_type: Mumukit.config.content_type,
        comment_type: Mumukit.config.comment_type,
        features: {
            query: query_hook?,
            expectations: expectations_hook?,
            feedback: feedback_hook?,
            secure: validation_hook?,
            stateful: Mumukit.config.stateful,
            preprocessor: Mumukit.config.preprocessor_enabled,

            sandboxed: any_hook_include?([:test, :query], Mumukit::Templates::WithIsolatedEnvironment),
            structured: any_hook_include?([:test], Mumukit::Templates::WithStructuredResults) || Mumukit.config.structured
        }
    }
  end

  private

  def any_hook_include?(hooks, mixin)
    hooks.any? { |it| hook_includes?(it, mixin) }
  end
end