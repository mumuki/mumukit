module Mumukit
  class Templates::MultiFileHook < Templates::FileHook
    include Mumukit::Templates::WithMultipleFiles

    def compile(request)
      return super(request) unless has_files?(request)

      self.request = request
      compile_file_content(request).map { |filename, content| write_tempfile!(content, filename) }
    end

    def run!(files)
      return super(files) unless has_files?(request)

      result, status = run_files!(*files)
      post_process_file(files, cleanup_raw_result(result), status)
    ensure
      files.each { |file| file.unlink }
    end
  end
end
