module Mumukit::Templates::WithMultipleFiles
  def files_of(request)
    request.to_stringified_h.select { |key, _| key.include? '.' }
  end
end
