require 'mumukit/inspection'

module Mumukit
  class Templates::ExpectationsHook < Mumukit::Hook
    SOURCE_EXPECTATION_EVALUATORS = {
      'SourceRepeats' => lambda { |source, target| source.scan(target).count > 1 },
      'SourceContains' => lambda { |source, target| source.include? target },
      'SourceEquals' => lambda { |source, target| source == target },
      'SourceEqualsIgnoreSpaces' => lambda { |source, target| source.delete(' ') == target.delete(' ') }
    }
    SOURCE_EXPECTATIONS = SOURCE_EXPECTATION_EVALUATORS.keys.flat_map { |it| [it, "Not:#{it}"] }

    def compile(request)
      { request: request, expectations: compile_expectations(request) }
    end

    def run!(spec)
      spec[:expectations][:source].map { |it| it.evaluate spec[:request][:content] }
    end

    private

    def compile_expectations(request)
      expectations = {ast: [], source: [], exceptions: [], custom: request[:custom_expectations] }
      request[:expectations].to_a.each do |it|
        fill_expectations it.deep_symbolize_keys, expectations
      end
      expectations
    end

    def fill_expectations(expectation, expectations)
      inspection = expectation[:inspection]
      if inspection&.start_with? 'Except:'
        expectations[:exceptions] << inspection[7..-1]
      elsif SOURCE_EXPECTATIONS.any? { |it| inspection.starts_with? it  }
        expectations[:source] << compile_source_expectation(expectation)
      else
        expectations[:ast] << compile_expectation(expectation)
      end
    end

    def compile_expectation(expectation)
      Mumukit::Inspection::Expectation.parse(expectation).as_v2.to_h
    end

    def compile_source_expectation(expectation)
      SourceExpectation.parse(expectation)
    end

    class SourceExpectation
      def initialize(expectation, evaluator)
        @expectation = expectation
        @evaluator = evaluator
      end

      def evaluate(content)
        { result: evaluate_inspection(content), expectation: @expectation.to_h }
      end

      def inspection
        @expectation.inspection
      end

      def self.parse(expectation)
        parsed = Mumukit::Inspection::Expectation.parse(expectation)
        evaluator = parse_evaluator(parsed.inspection)
        new parsed, evaluator
      end

      private

      def evaluate_inspection(content)
        inspection.negated? ^ @evaluator.call(content, inspection.target.value)
      end

      def self.parse_evaluator(inspection)
        SOURCE_EXPECTATION_EVALUATORS[inspection.type]
      end
    end
  end
end
