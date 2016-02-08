class Mumukit::Defaults::QueryHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    ['unimplemented', :aborted]
  end
end
