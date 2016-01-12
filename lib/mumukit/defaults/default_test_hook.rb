class Mumukit::DefaultTestHook < Mumukit::Hook
  def run!(compilation)
    ['unimplemented', :aborted]
  end

  def compile(request)
    request
  end
end