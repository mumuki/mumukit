module Mumukit::Templates::WithMultipleFiles
  def files_of(request)
    request.content.is_a?(Hash) ? request.content : {}
  end
end
