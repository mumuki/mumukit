class TestCompiler
  include Mumukit::FileTestCompiler
  def initialize(config = nil)
    @config = config
  end
end
