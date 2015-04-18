require 'tempfile'

module Mumukit::FileTestCompiler

  def create_tempfile
    Tempfile.new('mumuki.compile')
  end

  def create_compilation_file!(test, extra, content)
    file = create_tempfile
    file.write(compile(test, extra, content))
    file.close
    file
  end

end
