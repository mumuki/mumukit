require 'mulang'

module Mumukit
  class Templates::MulangExpectationsHook < Mumukit::Templates::ExpectationsHook
    LOGIC_SMELLS = Mulang::Expectation::LOGIC_SMELLS
    FUNCTIONAL_SMELLS = Mulang::Expectation::FUNCTIONAL_SMELLS
    OBJECT_ORIENTED_SMELLS = Mulang::Expectation::OBJECT_ORIENTED_SMELLS
    IMPERATIVE_SMELLS = Mulang::Expectation::IMPERATIVE_SMELLS
    EXPRESSIVENESS_SMELLS = Mulang::Expectation::EXPRESSIVENESS_SMELLS
    GENERIC_SMELLS = Mulang::Expectation::GENERIC_SMELLS

    required :language, 'You have to provide a Mulang-compatible language in order to use this hook'

    def run!(spec)
      super(spec) + run_mulang_analysis(compile_mulang_analysis(spec[:request], spec[:expectations]))
    end

    def compile_mulang_analysis(request, expectations)
      mulang_code(request).analysis({
        expectations: expectations[:ast],
        customExpectations: expectations[:custom],
        smellsSet: {
          tag: 'AllSmells',
          exclude: (expectations[:exceptions] + default_smell_exceptions)
        },
        domainLanguage: domain_language
      }.merge({
        originalLanguage: original_language,
        autocorrectionRules: autocorrection_rules.try { |it| positive_and_negative it }.presence,
        normalizationOptions: normalization_options(request).presence
      }.compact))
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

    def normalization_options(request)
      request.dig(:settings, :normalization_options) || {}
    end

    def autocorrection_rules
      {}
    end

    def original_language
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

    private

    def positive_and_negative(rules)
      rules.flat_map { |k, v| [[k, v], ["Not:#{k}", "Not:#{v}"]] }.to_h
    end
  end
end
