class Mumukit::Runtime
  include Mumukit::RuntimeShortcuts
  include Mumukit::RuntimeInfo

  def initialize(config)
    @config = config
    @hook_classes = {}
  end

  def hook_defined?(hook_name)
    hook_name.to_default_mumukit_hook_class rescue raise "Wrong hook #{hook_name}"

    Kernel.const_defined? hook_name.to_mumukit_hook_class_name
  end

  def hook_includes?(hook_name, mixin)
    hook_class(hook_name).included_modules.include?(mixin)
  end

  def new_hook(hook_name)
    hook_class(hook_name).new(@config)
  end

  def hook_class(hook_name)
    @hook_classes[hook_name] ||=
        if hook_defined? hook_name
          hook_name.to_mumukit_hook_class
        else
          hook_name.to_default_mumukit_hook_class
        end
  end
end

