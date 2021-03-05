module Mumukit::Metatest
  class InteractiveChecker < Checker

    def initialize(request)
      @request = request
    end

    def check_last_query_equals(_result, goal)
      expected = goal[:value]
      actual = query
      fail_t :check_last_query_equals, expected: expected, actual: actual unless expected == actual
    end

    def check_last_query_matches(_result, goal)
      regexp = goal[:regexp]
      fail_t :check_last_query_matches, regexp: regexp.inspect unless query.match?(regexp)
    end

    def check_last_query_fails(result, _goal)
      fail_t :check_last_query_fails unless result[:query][:status].failed?
    end

    def check_queries_match(result, goal)
      queries = [query] + @request.cookie.to_a
      fail_t :check_queries_match unless goal[:regexps].all? do |regexp|
        queries.any? { |query| query.match? regexp }
      end
    end

    def check_last_query_outputs(result, goal)
      compare_last_query_by(:check_last_query_outputs, result, goal) { |expected, actual| expected == actual }
    end

    def check_last_query_output_includes(result, goal)
      compare_last_query_by(:check_last_query_output_includes, result, goal) { |expected, actual| actual.include? expected }
    end

    def check_last_query_output_like(result, goal)
      compare_last_query_by(:check_last_query_output_like, result, goal) { |expected, actual| normalize(expected) == normalize(actual) }
    end

    def compare_last_query_by(sym, result, goal, &condition)
      expected = goal[:output]
      actual = result[:query][:result]
      fail_t sym, expected: expected, actual: actual unless condition.call expected, actual
    end

    def check_last_query_passes(result, _goal)
      fail_t :check_last_query_passes unless result[:query][:status].passed?
    end

    def check_query_passes(result, goal)
      fail_t :check_query_passes, query: goal[:query] unless result[:status].passed?
    end

    def check_query_fails(result, goal)
      fail_t :check_query_fails, query: goal[:query] unless result[:status].failed?
    end

    def check_query_outputs(result, goal)
      expected = goal[:output]
      actual = result[:goal]
      fail_t :check_query_outputs, query: goal[:query], expected: expected, actual: actual unless expected == actual
    end

    def render_success_output(_value)
      I18n.t locale(:goal_passed)
    end

    def fail_t(sym, *args)
      fail I18n.t locale(sym), *args
    end

    def locale(sym)
      'mumukit.interactive.' + sym.to_s
    end

    def normalize(a_string)
      a_string.delete(" \t\r\n").downcase
    end

    private

    def query
      @request.query.to_s.strip
    end
  end
end
