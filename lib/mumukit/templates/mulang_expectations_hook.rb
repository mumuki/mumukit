module Mumukit
  class Templates::MulangExpectationsHook < Mumukit::Hook
    include Mumukit::WithCommandLine

    required :language

    def run!(request)
      result = run_command "#{mulang_path} #{mulang_json request[:content], request[:expectations]}"
      make_response JSON.parse(result)
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

    def make_response(mulang_response)
      mulang_response['results']
    end

    def self.include_smells(value=true)
      if value
        include Mumukit::Templates::WithCodeSmells
      end
    end
  end
end