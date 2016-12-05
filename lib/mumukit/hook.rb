class Mumukit::Hook
  attr_reader :config

  include Mumukit::WithContentType

  def initialize(config=nil)
    @config = (config||{}).with_indifferent_access
  end

  def t(*args)
    I18n.t(*args)
  end

  def method_missing(name, *args, &block)
    super unless should_forward_to_config?(args, name, &block)
    @config[name]
  end

  def env
    Mumukit::Env.env
  end

  def logger
    env['rack.logger']
  end

  def should_forward_to_config?(args, name)
    args.length == 0 && !block_given? && @config[name]
  end

  def self.stateful_through(cookie_clazz)
    include Mumukit::Templates::WithCookie
    define_method :cookie_class do
      cookie_clazz
    end
  end
end
