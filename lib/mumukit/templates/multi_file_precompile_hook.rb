module Mumukit
  class Templates::MultiFilePrecompileHook < Mumukit::Hook
    include Mumukit::WithMultipleFiles

    def compile(request)
      files = files_of request
      content = files.empty? ? single_file_content(request) : multi_file_content(files)

      struct request.to_h.merge content: content
    end

    def main_file
      raise NotImplementedError
    end

    def consolidate(main_content, files)
      raise NotImplementedError
    end

    def single_file_content(request)
      request.content
    end

    def multi_file_content(files)
      return files.values.first if files.count == 1

      consolidate(files[main_file] || '', files)
    end
  end
end
