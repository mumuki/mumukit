module Mumukit::RuntimeShortcuts
  def feedback_runner
    new_hook :feedback_runner
  end

  def expectations_runner
    new_hook :expectations_runner
  end

  def test_hook
    new_hook :test
  end

  def query_runner
    new_hook :query_runner
  end

  def request_validator
    new_hook :request_validator
  end

  def metadata_publisher
    new_hook :metadata_publisher
  end
end