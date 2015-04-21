class TestRunner < Mumukit::Stub
  include Mumukit::CommandLineTestRunner

  def run_test_file!(file)
    post_process_file(file, *super)
  end

  def post_process_file(file, result, status)
    [result, status]
  end

  def run_test_command(file)
    raise 'You need to implement this method'
  end
end
