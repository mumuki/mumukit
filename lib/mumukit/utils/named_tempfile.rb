require 'tmpdir'
require 'fileutils'

module Mumukit
  class NamedTempfile < File
    def initialize(name)
      @tmp_dir = Dir.mktmpdir
      super("#{@tmp_dir}/#{name}", 'w+')
    end

    def unlink
      FileUtils.rm_rf @tmp_dir
    end
  end
end