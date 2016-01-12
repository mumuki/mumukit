module Mumukit
  class FileTestCompilerHook < Mumukit::Hook
    include Mumukit::WithTempfile

    def compile(request)
      write_tempfile! compile_file_content(request)

    end

    def compile_file_content(request)
      raise 'You need to implement this method'
    end
  end
end
