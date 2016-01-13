class Symbol
  def to_mumukit_hook_class_name
    "#{to_s.camelize.to_sym}Hook"
  end

  def to_mumukit_hook_class
    Kernel.const_get to_mumukit_hook_class_name
  end

  def to_default_mumukit_hook_class
    Kernel.const_get "Mumukit::Defaults::#{to_mumukit_hook_class_name}"
  end
end