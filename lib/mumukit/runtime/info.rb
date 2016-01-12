module Mumukit::RuntimeInfo
  def info
    {
        name: Mumukit.config.runner_name,
        version: Mumukit.config.runner_version,
        mumukit_version: Mumukit::VERSION,
        output_content_type: Mumukit.config.content_type,
        features: {
            structured: Mumukit.config.structured,

            query: hook_defined?(:query_runner),
            expectations: hook_defined?(:expectations_runner),
            feedback: hook_defined?(:feedback_runner),
            secure: hook_defined?(:request_validator),

            sandboxed: [:test, :query_runner].any? { |it| hook_includes?(it, Mumukit::WithIsolatedEnvironment) }
        }
    }
  end
end