class Mumukit::Defaults::ExpectationsHook < Mumukit::Hook
  def compile(request)
    request
  end

  def run!(request)
    []
  end
end
