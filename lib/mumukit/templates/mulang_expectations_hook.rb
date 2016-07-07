module Mumukit
  class Templates::MulangExpectationsHook < Mumukit::Hook
    include Mumukit::WithCommandLine

    required :language, 'You have to provide a Mulang-compatible language in order to use this hook'

    def compile(request)
      request
    end

    def run!(request)
      result = run_command "#{mulang_path} '#{mulang_input(request[:content], request[:expectations]).to_json}'"
      make_response JSON.parse(result[0])
    end

    def transform_content(content)
      content
    end

    def transform_expectations(expectations)
      expectations
    end

    def mulang_input(content, expectations)
      {
        expectations: transform_expectations(expectations),
        code: { content: transform_content(content), language: language}
      }
    end

    def make_response(mulang_output)
      mulang_output['results']
    end

    def self.include_smells(value=true)
      if value
        include Mumukit::Templates::WithCodeSmells
      end
    end
  end
end