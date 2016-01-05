module Mumukit::RuntimeShortcuts
  def feedback_runner
    new_hook :FeedbackRunner
  end

  def expectations_runner
    new_hook :ExpectationsRunner
  end

  def test_compiler
    new_hook :TestCompiler
  end

  def test_runner
    new_hook :TestRunner
  end

  def query_runner
    new_hook :QueryRunner
  end

  def request_validator
    new_hook :RequestValidator
  end

  def metadata_publisher
    new_hook :MetadataPublisher
  end
end