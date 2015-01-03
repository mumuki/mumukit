class TestRunner
  include Mumukit::CommandLineTestRunner
  def initialize(config)
    @config = config
  end
end
