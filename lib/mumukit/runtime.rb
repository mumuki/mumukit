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

  def new_hook(hook_name)
    hook_class(hook_name).new(@config)
  end

  private

  def hook_class(hook_name)
    @hook_classes[hook_name] ||= hook_class_or(hook_name, default_hook_class(hook_name))
  end

  def hook_class_or(hook_name, default_hook_class)
    k = Kernel.const_get(hook_name) if Kernel.const_defined?(hook_name)
    k || default_hook_class
  end

  def default_hook_class(hook_name)
    Kernel.const_get("Mumukit::Default#{hook_name}")
  end

end