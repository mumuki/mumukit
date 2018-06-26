module Mumukit::WithContentType
  def content_type
    @content_type ||= Mumukit::ContentType.parse content_type_config
  end

  def content_type_config
    Mumukit.config.content_type
  end
end
