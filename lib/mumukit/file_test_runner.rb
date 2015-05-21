class FileTestRunner < Mumukit::Stub
  def run_compilation!(file)
    post_process_file(file, *run_test_file!(file))
  ensure
    file.unlink
  end

  def post_process_file(file, result, status)
    [result, status]
  end

  def run_test_file!(file)
    [%x{#{run_test_command(file)}}, $?.success? ? :passed : :failed]
  end

  def run_test_command(file)
    raise 'You need to implement this method'
  end
end
