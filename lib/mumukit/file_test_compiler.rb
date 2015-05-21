require 'tempfile'

class Mumukit::FileTestCompiler < Mumukit::Stub

  def create_tempfile
    Tempfile.new('mumuki.compile')
  end

  def compile(test, extra, content)
    raise 'You need to implement this method'
  end

  def create_compilation_file!(test, extra, content)
    file = create_tempfile
    file.write(compile(test, extra, content))
    file.close
    file
  end

end
