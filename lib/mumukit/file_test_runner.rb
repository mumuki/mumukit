class FileTestRunner < Mumukit::Stub
  def run_test_file!(file)
    post_process_file(file, *raw_run_test_file!(file))
  end

  def post_process_file(file, result, status)
    [result, status]
  end

  def raw_run_test_file!(file)
    [%x{#{run_test_command(file)}}, $?.success? ? :passed : :failed]
  end

  def run_test_command(file)
    raise 'You need to implement this method'
  end
end
