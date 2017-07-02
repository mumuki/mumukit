require 'mumukit/inspection'

module Mumukit
  class Templates::MulangExpectationsHook < Mumukit::Templates::FileHook
    isolated false
    # TODO Support externalized languages
    required :language, 'You have to provide a Mulang-compatible language in order to use this hook'

    def tempfile_extension
      '.json'
    end

    def command_line(filename)
      # TODO avoid file generation
      "cat #{filename} | #{mulang_path} -s"
    end

    def post_process_file(file, result, status)
      parse_response JSON.pretty_parse(result)
    end

    def compile_file_content(request)
      compile_json_file_content(request).to_json
    end

    def compile_json_file_content(request)
      expectations, exceptions = compile_expectations_and_exceptions request
      {
          sample: {
            tag: 'CodeSample',
            language: language,
            content: compile_content(request[:content])
          },
          spec: {
            expectations: expectations,
            smellsSet: {
              tag: 'AllSmells',
              exclude: exceptions
            }
          }
      }
    end

    def compile_expectations_and_exceptions(request)
      expectations = []
      exceptions = []
      request[:expectations].each do |it|
        if it[:inspection]&.start_with? 'Except:'
          exceptions << it[:inspection][7..-1]
        else
          expectations << compile_expectation(it.deep_symbolize_keys)
        end
      end
      [expectations, exceptions]
    end

    def compile_content(content)
      content
    end

    def compile_expectation(expectation)
      Mumukit::Inspection::Expectation.parse(expectation).as_v2.to_h
    end

    def parse_response(response)
      response['expectationResults'].map do |it|
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
