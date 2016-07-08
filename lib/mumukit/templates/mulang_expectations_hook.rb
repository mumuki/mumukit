module Mumukit
  class Templates::MulangExpectationsHook < Mumukit::Templates::FileHook
    isolated false

    required :language, 'You have to provide a Mulang-compatible language in order to use this hook'

    def tempfile_extension
      '.json'
    end

    def command_line(filename)
      "cat #{filename} | #{mulang_path}"
    end

    def post_process_file(file, result, status)
      parse_response JSON.parse(result)
    end

    def compile_file_content(request)
      compile_json_file_content(request).to_json
    end

    def compile_json_file_content(request)
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