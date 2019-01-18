module Mumukit
  class Templates::MultiFileHook < Templates::FileHook
    include Mumukit::Templates::WithMultipleFiles

    def compile(request)
      return super(request) unless has_files?(request)

      self.request = request
      write_named_tempfiles! compile_file_content(request)
    end

    def run!(files)
      return super(files) unless has_files?(request)

      result, status = run_files!(*files)
      post_process_file(files, cleanup_raw_result(result), status)
    ensure
      [files].flatten.each { |file| file.unlink }
    end
  end
end
