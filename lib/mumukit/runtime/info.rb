module Mumukit::RuntimeInfo
  def info
    {
        name: Mumukit.runner_name,
        version: hook_class(:version)::VERSION,
        escualo_base_version: ENV['ESCUALO_BASE_VERSION'],
        escualo_service_version: ENV['ESCUALO_SERVICE_VERSION'],
        mumukit_version: Mumukit::VERSION,
        worker_image: Mumukit.config.docker_image,
        output_content_type: Mumukit.config.content_type,
        comment_type: Mumukit.config.comment_type,
        features: {
          precompile: precompile_hook?,
          query: query_hook?,
          try: try_hook?,
          expectations: expectations_hook?,
          feedback: feedback_hook?,
          secure: validation_hook?,
          stateful: Mumukit.config.stateful,
          multifile: Mumukit.config.multifile,
          preprocessor: Mumukit.config.preprocessor_enabled,
          settings: Mumukit.config.settings,

          sandboxed: any_hook_include?([:test, :query], Mumukit::Templates::WithIsolatedEnvironment),
          structured: any_hook_include?([:test], Mumukit::Templates::WithStructuredResults) || Mumukit.config.structured
        }
    }
  end

  private

  def any_hook_include?(hooks, mixin)
    hooks.any? { |it| hook_includes?(it, mixin) }
  end
end
