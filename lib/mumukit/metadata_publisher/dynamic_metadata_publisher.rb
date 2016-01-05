class Mumukit::DynamicMetadataPublisher
  def metadata(path)
    dynamic_metadata(path).
        merge(language_metadata).
        merge(test_framework_metadata)
  end

  def test_framework_metadata
    {}
  end

  def language_metadata
    {}
  end

  def dynamic_metadata(path)
    {
        mumukit_version: Mumukit.VERSION,
        url: path,
        name: Mumukit.config.runner_name,
        version: Mumukit.config.runner_version,
        features: {
            query: runtime.hook_defined?(:QueryRunner),
            structured: true,
            expectations: runtime.hook_defined?(:ExpectationsRunner),
            feedback: runtime.hook_defined?(:FeedbackRunner),
            secure: runtime.hook_defined?(:ValidatorRunner),
            sandboxed: (runtime.hook_includes?(:TestRunner, Mumukit::WithIsolatedEnvironment) ||
                runtime.hook_includes?(:QueryRunner, Mumukit::WithIsolatedEnvironment))
        },
        output_content_type: Mumukit.config.content_type
    }
  end
end