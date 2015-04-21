class TestCompiler < Mumukit::Stub
  include Mumukit::FileTestCompiler

  def compile(test, extra, content)
    raise 'You need to implement this method'
  end
end
