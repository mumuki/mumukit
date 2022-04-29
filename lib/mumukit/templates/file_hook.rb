module Mumukit
  class Templates::FileHook < Mumukit::Hook
    include Mumukit::WithTempfile

    attr_accessor :request

    def compile(request)
      self.request = request
      write_tempdir! "solution#{tempfile_extension}" => compile_file_content(request)
    end

    def run!(dir)
      result, status = run_dir!(dir)
      post_process_file(dir.files.first, cleanup_raw_result(result), status)
    ensure
      FileUtils.rm_rf dir.path
    end

    def cleanup_raw_result(result)
      mask_tempfile_references(result.force_encoding('UTF-8'), masked_tempfile_path)
    end

    def post_process_file(file, result, status)
      [result, status]
    end

    required :compile_file_content
    required :command_line

    required :run_dir!, 'Wrong configuration. You must include an environment mixin'

    def masked_tempfile_path
      @masked_tempfile_path ||= "#{t 'mumukit.masked_tempfile_basename'}#{tempfile_extension}"
    end

    def self.line_number_offset(offset, options={})
      include Mumukit::Templates::WithLineNumberOffset

      define_method(:line_number_offset) do
        extra_offset = options[:include_extra] && request.extra ? request.extra.lines.length : 0
        offset + extra_offset
      end
    end

    def self.metatested(value=true)
      if value
        include Mumukit::Templates::WithMetatest
        include Mumukit::Templates::WithMetatestResults
      end
    end

    def self.structured(value=true, separator: nil)
      if value
        @separator = separator
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

    def self.mashup(*args, &map_block)
      include Mumukit::Templates::WithMashupFileContent
      define_method(:map_mashup_fields, &map_block) if block_given?

      args = args.present? ? args : [:extra, :content, :test]

      if args
        define_method(:mashup_fields) { args }
      end
    end

    def self.with_error_patterns
      include Mumukit::Templates::WithErrorPatterns
    end
  end
end
