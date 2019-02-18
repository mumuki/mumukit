module Mumukit::Templates
  class QueryHook < FileHook
    def post_process_file(_file, result, status)
      error_patterns.each { |it| return it.transform(result, status) if it.matches? result } if status.failed?
      super
    end

    def error_patterns
      []
    end
  end
end
