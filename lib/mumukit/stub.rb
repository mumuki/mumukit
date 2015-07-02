class Mumukit::Stub
  attr_reader :config, :content_type

  def initialize(config=nil)
    @config = (config||{}).with_indifferent_access
    @content_type = Mumukit::ContentType.parse Mumukit.config.content_type
  end

  def t(*args)
    I18n.t(*args)
  end

end
