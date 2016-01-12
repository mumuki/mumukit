class Mumukit::DefaultTestRunnerHook < Mumukit::Hook
  def run_compilation!(compilation)
    ['unimplemented', :aborted]
  end
end