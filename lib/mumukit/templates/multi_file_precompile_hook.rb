module Mumukit
  class Templates::MultiFilePrecompileHook < Mumukit::Hook
    include Mumukit::Templates::WithMultipleFiles

    def compile(request)
      request
        .to_h
        .merge(content: files_content(request))
        .to_struct
    end

    def main_file
      raise NotImplementedError
    end

    def consolidate(main_content, files)
      raise NotImplementedError
    end

    private

    def files_content(request)
      files = files_of request
      if files.empty?
        no_files_content request
      elsif files.count == 1
        single_file_content files
      else
        multi_file_content files
      end
    end

    def no_files_content(request)
      request.content
    end

    def single_file_content(files)
      files.values.first
    end

    def multi_file_content(files)
      consolidate main_file_content(files), files
    end

    def main_file_content(files)
      files[main_file] || ''
    end
  end
end
