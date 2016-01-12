module Mumukit::RuntimeInfo
  def info
    {
        name: Mumukit.config.runner_name,
        version: Mumukit.config.runner_version,
        mumukit_version: Mumukit::VERSION,
        output_content_type: Mumukit.config.content_type,
        features: {
            structured: Mumukit.config.structured,

            query: hook_defined?(:QueryRunnerHook),
            expectations: hook_defined?(:ExpectationsRunnerHook),
            feedback: hook_defined?(:FeedbackRunnerHook),
            secure: hook_defined?(:RequestValidatorHook),

            sandboxed: [:TestHook, :QueryRunnerHook].any? { |it| hook_includes?(it, Mumukit::WithIsolatedEnvironment) }
        }
    }
  end
end