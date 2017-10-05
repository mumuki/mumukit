class Mumukit::Defaults::TryHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(compilation)
    ['unimplemented', :aborted]
  end
end