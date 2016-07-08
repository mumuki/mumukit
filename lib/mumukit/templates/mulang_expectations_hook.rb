module Mumukit
  class Templates::MulangExpectationsHook < Mumukit::Hook
    include Mumukit::WithCommandLine

    required :language, 'You have to provide a Mulang-compatible language in order to use this hook'

    def compile(request)
      {
          expectations: request[:expectations].map { |it| compile_expectation(it.deep_symbolize_keys) },
          code: {
              content: compile_content(request[:content]),
              language: language}
      }
    end

    def compile_content(content)
      content
    end

    def compile_expectation(expectation)
      (expectation[:verb].present? ? {tag: :Advanced} : {tag: :Basic}).merge(expectation)
    end

    def run!(request)
      result = run_command "#{mulang_path} '#{request.to_json}'"
      parse_response JSON.parse(result[0])
    end

    def parse_response(response)
      response['results'].map do |it|
        {result: it['result'],
         expectation: parse_expectation(it['expectation'])}
      end
    end

    def parse_expectation(expectation)
      expectation.deep_symbolize_keys.except(:tag)
    end


    def self.include_smells(value=true)
      if value
        include Mumukit::Templates::WithCodeSmells
      end
    end
  end
end