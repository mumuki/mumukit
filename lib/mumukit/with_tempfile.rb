require 'tempfile'

module Mumukit
  module WithTempfile
    def create_tempfile
      Tempfile.new('mumuki.compile')
    end

    def write_tempfile!(content)
      with_tempfile do |file|
        file.write(content)
      end
    end

    def with_tempfile
      file = create_tempfile
      yield file
      file.close
      file
    end

  end
end
