require 'tempfile'

module Mumukit
  module WithTempfile
    def create_tempfile
      Tempfile.new('mumuki.compile')
    end

    def write_tempfile!(content)
      file = create_tempfile
      file.write(content)
      file.close
      file
    end
  end
end
