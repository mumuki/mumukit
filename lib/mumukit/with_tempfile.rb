require 'tempfile'

module Mumukit
  module WithTempfile
    def create_tempfile
      Tempfile.new(['mumuki.compile', tempfile_extension])
    end

    def tempfile_extension
      ''
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

    def hide_tempfile_references(string)
      string.gsub(/\/tmp\/mumuki\.compile(.*)#{tempfile_extension}/, "mumuki#{tempfile_extension}")
    end
  end
end
