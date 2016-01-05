class Mumukit::Runtime

  def initialize(config)
    @config = config
    @hook_classes = {}
  end

  def feedback_runner
    new_hook :FeedbackRunner
  end

  def expectations_runner
    new_hook :ExpectationsRunner
  end

  def test_compiler
    new_hook :TestCompiler
  end

  def test_runner
    new_hook :TestRunner
  end

  def query_runner
    new_hook :QueryRunner
  end

  def request_validator
    new_hook :RequestValidator
  end

  def metadata_publisher
    new_hook :MetadataPublisher
  end

  def hook_defined?(hook_name)
    Kernel.const_defined?(hook_name)
  end

  def hook_includes?(hook_name, mixin)
    hook_class(hook_name).included_modules.include?(mixin)
  end

  def new_hook(hook_name)
    hook_class(hook_name).new(@config)
  end

  private

  def hook_class(hook_name)
    @hook_classes[hook_name] ||= hook_class_or(hook_name, default_hook_class(hook_name))
  end

  def hook_class_or(hook_name, default_hook_class)
    if hook_defined? hook_name
      Kernel.const_get(hook_name)
    else
      default_hook_class
    end
  end

  def default_hook_class(hook_name)
    Kernel.const_get("Mumukit::Default#{hook_name}")
  end

end