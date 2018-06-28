class Mumukit::Runtime
  attr_reader :config

  DefaultHooks = {
    expectations: Mumukit::Defaults::ExpectationsHook,
    feedback: Mumukit::Defaults::FeedbackHook,
    metadata: Mumukit::Defaults::MetadataHook,
    precompile: Mumukit::Defaults::PrecompileHook,
    query: Mumukit::Defaults::QueryHook,
    test: Mumukit::Defaults::TestHook,
    try: Mumukit::Defaults::TryHook,
    validation: Mumukit::Defaults::ValidationHook,
    version: Mumukit::Defaults::VersionHook
  }

  def initialize(settings = {})
    @hooks = settings[:hooks] || {}
    @config = self.class.default_config.merge(settings[:config] || {}).to_struct
  end

  def hook_defined?(hook_name)
    @hooks.include? hook_name
  end

  def hook_includes?(hook_name, mixin)
    hook_class(hook_name).included_modules.include?(mixin)
  end

  def new_hook(hook_name)
    hook_class(hook_name).new(@config)
  end

  def hook_class(hook_name)
    @hooks[hook_name] || DefaultHooks[hook_name]
  end

  def info
    {
        name: config.name,
        version: hook_class(:version)::VERSION,
        escualo_base_version: ENV['ESCUALO_BASE_VERSION'],
        escualo_service_version: ENV['ESCUALO_SERVICE_VERSION'],
        mumukit_version: Mumukit::VERSION,
        worker_image: config.docker_image,
        output_content_type: config.content_type,
        comment_type: config.comment_type,
        repo_url: config.repo_url || default_repo_url,
        features: {
            precompile: hook_defined?(:precompile),
            query: hook_defined?(:query),
            try: hook_defined?(:try),
            expectations: hook_defined?(:expectations),
            feedback: hook_defined?(:feedback),
            secure: hook_defined?(:validation),
            stateful: config.stateful,
            preprocessor: config.preprocessor_enabled,

            sandboxed: any_hook_include?([:test, :query], Mumukit::Templates::WithIsolatedEnvironment),
            structured: any_hook_include?([:test], Mumukit::Templates::WithStructuredResults) || config.structured
        }
    }
  end

  def self.default_config
    {
      limit_script: File.join(__dir__, '..', '..', 'bin', 'limit'),
      content_type: :plain,
      comment_type: Mumukit::Directives::CommentType::Cpp,
      preprocessor_enabled: true,
      structured: false,
      stateful: false,
      command_time_limit: 4,
      command_size_limit: 1024,
      process_expectations_on_empty_content: false,
      run_test_hook_on_empty_test: false
    }
  end

  def self.default_settings
    default_config.merge(hooks: {})
  end

  private

  def any_hook_include?(hooks, mixin)
    hooks.any? { |it| hook_includes?(it, mixin) }
  end

  def default_repo_url
    "https://github.com/mumuki/mumuki-#{config.name}-runner"
  end
end
