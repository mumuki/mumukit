require 'tempfile'
require 'tmpdir'

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

    def write_tempdir!(files)
      dir = Dir.mktmpdir
      files.map do |filename, content|
        File.open("#{dir}/#{filename.sanitize_as_filename}", 'w') { |file| file.write content; file }
      end.try { |it| struct dir: dir, files: it }
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
