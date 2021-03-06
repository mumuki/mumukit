module Mumukit
  class Templates::TryHook < Templates::FileHook
    def compile(request)
      request_goal = request.goal.with_indifferent_access

      @goal = {postconditions: [[request_goal[:kind], request_goal]]}
      @checker = checker_for request
      super request
    end

    def post_process_file(file, result, status)
      structured_results = to_structured_results(file, result, status)
      check_results = @checker.check structured_results, @goal
      [check_results[2], check_results[1], structured_results[:query]]
    end

    def checker_for(request)
      Metatest::InteractiveChecker.new request, **checker_options
    end

    def checker_options
      {}
    end

    required :to_structured_results
  end
end
