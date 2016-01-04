module Mumukit
  class FileTestCompiler < Mumukit::Hook
    include Mumukit::WithTempfile

    def compile(request)
      raise 'You need to implement this method'
    end

    def create_compilation!(request)
      write_tempfile! compile(request)
    end

  end
end
