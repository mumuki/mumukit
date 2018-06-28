class Mumukit::Hook
  attr_reader :config

  include Mumukit::WithContentType

  def initialize(config = struct)
    @config = config
  end

  def t(*args)
    I18n.t(*args)
  end

  def env
    Mumukit::Env.env
  end

  def logger
    env['rack.logger']
  end

  def self.stateful_through(cookie_clazz)
    include Mumukit::Templates::WithCookie
    define_method :cookie_class do
      cookie_clazz
    end
  end
end
