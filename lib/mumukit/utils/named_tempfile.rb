require 'fileutils'
require 'tmpdir'

module Mumukit
  class NamedTempfile < File
    def initialize(name, tempdir = Dir.mktmpdir)
      @tempdir = tempdir
      super("#{tempdir}/#{name}", 'w+')
    end

    def unlink
      FileUtils.rm_rf @tempdir
    end
  end
end