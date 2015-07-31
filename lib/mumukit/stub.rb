class Mumukit::Stub
  attr_reader :config, :content_type

  def initialize(config=nil)
    @config = (config||{}).with_indifferent_access
    @content_type = Mumukit::ContentType.parse Mumukit.config.content_type
  end

  def t(*args)
    I18n.t(*args)
  end

  def method_missing(name, *args, &block)
    super unless should_forward_to_config?(args, name, &block)
    @config[name]
  end

  def should_forward_to_config?(args, name)
    args.length == 0 && !block_given? && @config[name]
  end

end
