module Mumukit
  class Templates::MultiFileHook < Templates::FileHook
    include Mumukit::Templates::WithMultipleFiles

    def compile(request)
      return super.compile(request) if files_of(request).empty?

      self.request = request
      compile_file_content(request).map { |filename, content| write_tempfile!(content, filename) }
    end

    def run!(files)
      return super.run!(files) if files_of(request).empty?

      result, status = run_files!(*files)
      post_process_file(files, cleanup_raw_result(result), status)
    ensure
      files.each { |file| file.unlink }
    end
  end
end
