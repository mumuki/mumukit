module Mumukit::Templates::WithMultipleFiles
  def files_of(request)
    raise 'You need to enable Mumukit.config.multifile first!' unless Mumukit.config.multifile
    has_files?(request) ? request.content : {}
  end

  def has_files?(request)
    request.content.is_a?(Hash)
  end
end
