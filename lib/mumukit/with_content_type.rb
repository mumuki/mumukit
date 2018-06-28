module Mumukit::WithContentType
  def content_type
    @content_type ||= Mumukit::ContentType.parse config.content_type
  end
end
