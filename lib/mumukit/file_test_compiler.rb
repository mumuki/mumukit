require 'tempfile'

module Mumukit::FileTestCompiler

  def create_compilation_file!(test, extra, content)
    file = Tempfile.new('mumuki.compile')
    file.write(compile(test, extra, content))
    file.close
    file
  end

end
