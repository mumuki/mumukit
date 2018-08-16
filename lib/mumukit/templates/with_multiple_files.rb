module Mumukit::Templates::WithMultipleFiles
  def files_of(request)
    raise 'You need to enable multifile support first!' unless Mumukit.config.multifile
    raise "content must be a hash, but it was #{request.content}" unless request.content.is_a?(Hash)
    request.content
  end
end
