class Symbol
  def to_mumukit_hook_class_name
    "#{Mumukit.prefix}#{to_simple_mumukit_hook_class_name}"
  end

  def to_simple_mumukit_hook_class_name
    "#{to_s.camelize.to_sym}Hook"
  end

  def to_mumukit_hook_class
    to_mumukit_hook_class_name.constantize
  end

  def to_default_mumukit_hook_class
    "Mumukit::Defaults::#{to_simple_mumukit_hook_class_name}".constantize
  end
end