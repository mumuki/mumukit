module Mumukit
  class Templates::MultiFileHook < Mumukit::Templates::FileHook
    def compile(request)
      self.request = request
      compile_file_content(request).map { |filename, content| write_tempfile!(content, filename) }
    end

    def run!(files)
      result, status = run_files!(*files)
      post_process_file(files, cleanup_raw_result(result), status)
    ensure
      files.each { |file| file.unlink }
    end
  end
end
