module Mumukit
  class Templates::MulangExpectationsHook < Mumukit::Hook
    include Mumukit::WithCommandLine

    required :language

    def run!(request)
      run_command "#{mulang_path} #{mulang_json request[:content], request[:expectations]}"
    end

    def transform_content(content)
      content
    end

    def mulang_json(content, expectations)
      {
        expectations: expectations,
        code: { content: transform_content(content), language: language}
      }
    end
  end
end