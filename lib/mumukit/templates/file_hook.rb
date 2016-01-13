module Mumukit
  class Templates::FileHook < Mumukit::Hook
    include Mumukit::WithTempfile

    def compile(request)
      write_tempfile! compile_file_content(request)
    end

    def run!(file)
      post_process_file(file, *run_file!(file))
    ensure
      file.unlink
    end

    def post_process_file(file, result, status)
      [result, status]
    end

    def compile_file_content(request)
      raise 'You need to implement this method'
    end

    def run_file!(*args)
      raise 'Wrong configuration. You must include an environment mixin'
    end

    def command_line(filename)
      raise 'You need to implement this method'
    end

    def self.isolated(value=true)
      if value
        include Mumukit::Templates::WithIsolatedEnvironment
      else
        include Mumukit::Templates::WithEmbeddedEnvironment
      end
    end

    def self.mashup(*args)
      include Mumukit::Templates::WithMashupFileContent

      args = args.present? ? args : [:extra, :content, :test]

      if args
        define_method(:mashup_fields) { args }
      end
    end
  end
end
