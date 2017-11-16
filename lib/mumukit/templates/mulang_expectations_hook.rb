require 'mumukit/inspection'
require 'mulang'

module Mumukit
  class Templates::MulangExpectationsHook < Mumukit::Hook
    LOGIC_SMELLS = %w(UsesCut UsesFail UsesUnificationOperator HasRedundantReduction)
    FUNCTIONAL_SMELLS = %w(HasRedundantParameter HasRedundantGuards)
    OBJECT_ORIENTED_SMELLS = %w(DoesNullTest ReturnsNull)
    IMPERATIVE_SMELLS = %w(HasRedundantLocalVariableReturn HasAssignmentReturn)
    EXPRESSIVENESS_SMELLS = %w(HasTooShortBindings HasWrongCaseBindings HasMisspelledBindings)
    GENERIC_SMELLS = %w(IsLongCode HasCodeDuplication HasRedundantLambda HasRedundantIf DoesTypeTest HasRedundantBooleanComparison)

    required :language, 'You have to provide a Mulang-compatible language in order to use this hook'

    def compile(request)
      expectations, exceptions = compile_expectations_and_exceptions request
      mulang_code(request).analysis(
        expectations: expectations,
        smellsSet: {
          tag: 'AllSmells',
          exclude: (exceptions + default_smell_exceptions)
        },
        domainLanguage: domain_language)
    end

    def run!(analysis)
      parse_response Mulang.analyse(analysis)
    rescue JSON::ParserError
      raise Mumukit::CompilationError, "Can not handle mulang results for analysis #{analysis}"
    end


    def domain_language
      {
        caseStyle: "CamelCase",
        minimumIdentifierSize: 3,
        jargon: []
      }
    end

    def default_smell_exceptions
      []
    end

    def mulang_code(request)
      Mulang::Code.new(mulang_language, compile_content(request[:content]))
    end

    def mulang_language
      language == 'Mulang' ? Mulang::Language::External.new :  Mulang::Language::Native.new(language)
    end

    def compile_expectations_and_exceptions(request)
      expectations = []
      exceptions = []
      request[:expectations].each do |it|
        fill_expectations_and_excetions it.deep_symbolize_keys, expectations, exceptions
      end
      [expectations, exceptions]
    end

    def fill_expectations_and_excetions(expectation, expectations, exceptions)
      inspection = expectation[:inspection]
      if inspection&.start_with? 'Except:'
        exceptions << inspection[7..-1]
      else
        expectations << compile_expectation(expectation)
      end
    end

    def compile_content(content)
      content
    end

    def compile_expectation(expectation)
      Mumukit::Inspection::Expectation.parse(expectation).as_v2.to_h
    end

    def parse_response(response)
      if response['tag'] == 'AnalysisFailed'
        raise Mumukit::CompilationError, response['reason']
      end
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
