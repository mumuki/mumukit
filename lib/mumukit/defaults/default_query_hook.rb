class Mumukit::DefaultQueryHook < Mumukit::Hook
  def run!(request)
    ['unimplemented', :aborted]
  end
end
