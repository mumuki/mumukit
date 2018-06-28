module Mumukit::Runner::Compilation
  def compile_and_run!(hook_name, request)
    hook = runtime.new_hook(hook_name)
    compilation = hook.compile(request)
    hook.run!(compilation)
  rescue Mumukit::CompilationError => e
    [e.message, :errored]
  end
end
