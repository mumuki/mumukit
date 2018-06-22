module Mumukit::Runner::Compilation
  def compile_and_run!(hook, request)
    compilation = hook.compile(request)
    hook.run!(compilation)
  rescue Mumukit::CompilationError => e
    [e.message, :errored]
  end
end
