module Mumukit::WithContentType
  def content_type
    @content_type ||= Mumukit::ContentType.parse Mumukit.config.content_type
  end
end