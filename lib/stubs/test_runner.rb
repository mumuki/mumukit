class TestRunner
  include Mumukit::CommandLineTestRunner
  def initialize(config=nil)
    @config = config
  end
end
