class Mumukit::Stub
  attr_reader :config

  def initialize(config=nil)
    @config = config
  end

  def t(*args)
    I18n.t(*args)
  end
end
