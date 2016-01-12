class Mumukit::DefaultTestRunnerHook < Mumukit::Hook
  def run!(compilation)
    ['unimplemented', :aborted]
  end
end