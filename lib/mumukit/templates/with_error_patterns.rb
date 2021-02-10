module Mumukit::Templates
  module WithErrorPatterns
    def post_process_file(_file, result, status)
      pattern = error_patterns.find { |it| it.matches? result, status }
      pattern ? pattern.transform(result, status) : super
    end

    def error_patterns
      []
    end
  end
end
