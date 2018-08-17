module Mumukit::Templates::WithMultipleFiles
  def files_of(request)
    raise 'You need to enable Mumukit.config.multifile first!' unless Mumukit.config.multifile
    request.content.is_a?(Hash) ? request.content : {}
  end
end
