module Mumukit::Templates::WithMultipleFiles
  def files_of(request)
    raise 'You need to enable multifile support first!' unless Mumukit.config.multifile_support
    raise 'content must be a hash' unless request.content.is_a?(Hash)
    request.content
  end
end
