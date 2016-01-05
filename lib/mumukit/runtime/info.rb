module Mumukit::RuntimeInfo
  def info
    {
        name: Mumukit.config.runner_name,
        version: Mumukit.config.runner_version,
        mumukit_version: Mumukit::VERSION,
        output_content_type: Mumukit.config.content_type,
        features: {
            structured: Mumukit.config.structured,

            query: hook_defined?(:QueryRunner),
            expectations: hook_defined?(:ExpectationsRunner),
            feedback: hook_defined?(:FeedbackRunner),
            secure: hook_defined?(:RequestValidator),

            sandboxed: [:TestRunner, :QueryRunner].any? { |it| hook_includes?(it, Mumukit::WithIsolatedEnvironment) }
        }
    }
  end
end