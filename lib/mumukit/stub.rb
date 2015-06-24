class Mumukit::Stub
  attr_reader :config, :content_type

  def initialize(config)
    @config = (config || {content_type: :plain}).with_indifferent_access
    @content_type = self.class.parse_content_type @config['content_type']
  end

  def t(*args)
    I18n.t(*args)
  end


  def self.parse_content_type(s)
    Kernel.const_get "Mumukit::ContentType::#{s.to_s.titlecase}"
  rescue raise
    "unknown content_type #{config['content_type']}"
  end

end
