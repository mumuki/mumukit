module Mumukit::RuntimeShortcuts
  def feedback_runner
    new_hook :FeedbackRunnerHook
  end

  def expectations_runner
    new_hook :ExpectationsRunnerHook
  end

  def test_hook
    new_hook :TestHook
  end

  def query_runner
    new_hook :QueryRunnerHook
  end

  def request_validator
    new_hook :RequestValidatorHook
  end

  def metadata_publisher
    new_hook :MetadataPublisherHook
  end
end