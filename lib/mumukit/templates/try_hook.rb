module Mumukit
  class Templates::TryHook < Templates::FileHook
    def compile(request)
      @goal = {postconditions: [[request.goal.with_indifferent_access[:kind], request.goal]]}
      @checker = Metatest::InteractiveChecker.new request
      super request
    end

    def check(results)
      @checker.check(results, @goal)
    end
  end
end
