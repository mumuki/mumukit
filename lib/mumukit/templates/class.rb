class Class
  def required(name, message=nil)
    message ||= "You need to implement method #{name}"
    define_method name do |*|
      raise message
    end
  end
end