class Mumukit::DefaultQueryRunnerHook < Mumukit::Hook
  def run!(request)
    ['unimplemented', :aborted]
  end
end
