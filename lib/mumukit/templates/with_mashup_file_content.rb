module Mumukit
  module Templates::WithMashupFileContent
    def compile_file_content(request)
      mashup_fields.map { |field| request.public_send field }.join("\n")
    end

    def mashup_fields
      raise 'must define mashup fields'
    end
  end
end
