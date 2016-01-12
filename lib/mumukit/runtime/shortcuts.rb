module Mumukit::RuntimeShortcuts
  def method_missing(name, *args, &block)
    n = name.to_s
    if n =~ /(.*)_hook\?/
      hook_defined? $1.to_sym
    elsif  n =~ /(.*)_hook/
      new_hook $1.to_sym
    else
      super
    end
  end
end