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

    def mask_tempfile_references(string, masked_tempfile_path)
      string.gsub(/\/tmp\/mumuki\.compile(.+?)#{tempfile_extension}/, masked_tempfile_path)
    end
  end
end
