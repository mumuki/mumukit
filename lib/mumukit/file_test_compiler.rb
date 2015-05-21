module Mumukit
  class FileTestCompiler < Mumukit::Stub
    include Mumukit::WithTempfile

    def compile(test, extra, content)
      raise 'You need to implement this method'
    end

    def create_compilation!(test, extra, content)
      write_tempfile! compile(test, extra, content)
    end

  end
end
