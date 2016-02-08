module Mumukit::RuntimeInfo
  def info
    {
        name: Mumukit.config.runner_name,
        version: Mumukit.config.runner_version,
        mumukit_version: Mumukit::VERSION,
        output_content_type: Mumukit.config.content_type,
        features: {
            query: query_hook?,
            expectations: expectations_hook?,
            feedback: feedback_hook?,
            secure: validation_hook?,

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