module Mumukit
  class FileTestHook < Mumukit::Hook
    include Mumukit::WithTempfile

    def compile(request)
      write_tempfile! compile_file_content(request)
    end

    def run!(file)
      post_process_file(file, *run_test_file!(file))
    ensure
      file.unlink
    end

    def post_process_file(file, result, status)
      [result, status]
    end

    def compile_file_content(request)
      raise 'You need to implement this method'
    end

    def run_test_file!(*args)
      raise 'Wrong configuration. You must include an environment mixin'
    end

    def run_test_command(filename)
      raise 'You need to implement this method'
    end
  end
end
