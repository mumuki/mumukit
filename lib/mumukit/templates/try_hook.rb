module Mumukit
  class Templates::TryHook < Templates::FileHook
    def compile(request)
      @goal = {postconditions: [[request.goal.with_indifferent_access[:kind], request.goal]]}
      @checker = Metatest::InteractiveChecker.new request
      super request
    end

    def post_process_file(file, result, status)
      structured_results = to_structured_results(file, result, status)
      check_results = @checker.check structured_results, @goal
      [check_results[2], check_results[1], structured_results[:query]]
    end

    required :to_structured_results
  end
end
