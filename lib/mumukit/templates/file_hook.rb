module Mumukit
  class Templates::FileHook < Mumukit::Hook
    include Mumukit::WithTempfile

    def compile(request)
      write_tempfile! compile_file_content(request)
    end

    def run!(file)
      result, status = run_file!(file)
      post_process_file(file, cleanup_raw_result(result), status)
    ensure
      file.unlink
    end

    def cleanup_raw_result(result)
      mask_tempfile_references(result.force_encoding('UTF-8'), masked_tempfile_path)
    end

    def post_process_file(file, result, status)
      [result, status]
    end

    required :compile_file_content
    required :command_line

    required :run_file!, 'Wrong configuration. You must include an environment mixin'

    def masked_tempfile_path
      @masked_tempfile_path ||= "#{t 'mumukit.solution'}#{tempfile_extension}"
    end

    def self.line_number_offset(offset)
      include Mumukit::Templates::WithLineNumberOffset
      define_method(:line_number_offset) { offset }
    end

    def self.metatested(value=true)
      if value
        include Mumukit::Templates::WithMetatest
        include Mumukit::Templates::WithMetatestResults
      end
    end

    def self.structured(value=true)
      if value
        include Mumukit::Templates::WithStructuredResults
      end
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
