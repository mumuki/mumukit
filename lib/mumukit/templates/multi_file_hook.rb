module Mumukit
  class Templates::MultiFileHook < Templates::FileHook
    include Mumukit::Templates::WithMultipleFiles

    def compile(request)
      return super unless has_files?(request)

      self.request = request
      write_tempdir! compile_file_content(request)
    end

    def run!(tempdir)
      return super unless has_files?(request)

      begin
        result, status = run_dir!(tempdir)
        post_process_file(tempdir.files, cleanup_raw_result(result), status)
      ensure
        FileUtils.rm_rf tempdir.path
      end
    end
  end
end
