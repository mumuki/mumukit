module Mumukit
  module Templates::WithMashupFileContent
    def compile_file_content(request)
      map_mashup_fields(mashup_fields.map { |field| request.public_send field }).join("\n")
    end

    def mashup_fields
      raise 'must define mashup fields'
    end

    def map_mashup_fields(fields)
    	fields
    end
  end
end
