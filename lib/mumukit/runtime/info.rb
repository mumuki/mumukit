module Mumukit::RuntimeInfo
  def info
    {
        name: Mumukit.config.runner_name,
        version: Mumukit.config.runner_version,
        mumukit_version: Mumukit::VERSION,
        output_content_type: Mumukit.config.content_type,
        features: {
            structured: Mumukit.config.structured,

            query: query_hook?,
            expectations: expectations_hook?,
            feedback: feedback_hook?,
            secure: validation_hook?,

            sandboxed: [:test, :query].any? { |it| hook_includes?(it, Mumukit::WithIsolatedEnvironment) }
        }
    }
  end
end