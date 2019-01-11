require 'tempfile'
require 'tmpdir'

module Mumukit
  module WithTempfile
    def create_tempfile
      Tempfile.new(['mumuki.compile', tempfile_extension])
    end

    def create_tempfile_as(name)
      File.new("#{Dir.mktmpdir}/#{name}", 'w+')
    end

    def tempfile_extension
      ''
    end

    def write_tempfile!(content, name = nil)
      with_tempfile(name) do |file|
        file.write(content)
      end
    end

    def with_tempfile(name = nil)
      file = name.nil? ? create_tempfile : create_tempfile_as(name)
      yield file
      file.close
      file
    end

    def mask_tempfile_references(string, masked_tempfile_path)
      string.gsub(/\/tmp\/mumuki\.compile(.+?)#{tempfile_extension}/, masked_tempfile_path)
    end
  end
end
