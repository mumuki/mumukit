require 'mulang'

module Mumukit
  class Templates::MulangExpectationsHook < Mumukit::Templates::ExpectationsHook
    LOGIC_SMELLS = %w(UsesCut UsesFail UsesUnificationOperator HasRedundantReduction)
    FUNCTIONAL_SMELLS = %w(HasRedundantParameter HasRedundantGuards)
    OBJECT_ORIENTED_SMELLS = %w(DoesNullTest ReturnsNull)
    IMPERATIVE_SMELLS = %w(HasRedundantLocalVariableReturn HasAssignmentReturn)
    EXPRESSIVENESS_SMELLS = %w(HasTooShortIdentifiers HasWrongCaseIdentifiers HasMisspelledIdentifiers)
    GENERIC_SMELLS = %w(IsLongCode HasCodeDuplication HasRedundantLambda HasRedundantIf DoesTypeTest HasRedundantBooleanComparison HasEmptyIfBranches)

    required :language, 'You have to provide a Mulang-compatible language in order to use this hook'

    def run!(spec)
      super(spec) + run_mulang_analysis(compile_mulang_analysis(spec[:request], spec[:expectations]))
    end

    def compile_mulang_analysis(request, expectations)
      mulang_code(request).analysis(
        expectations: expectations[:ast],
        customExpectations: expectations[:custom],
        smellsSet: {
          tag: 'AllSmells',
          exclude: (expectations[:exceptions] + default_smell_exceptions)
        },
        domainLanguage: domain_language)
    end

    def run_mulang_analysis(analysis)
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

    def compile_content(content)
      content
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
