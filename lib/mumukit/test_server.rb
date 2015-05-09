require 'yaml'

class Mumukit::TestServer
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def run!(request)
    content = request['content']

    test_results = run_tests! config, request['test'], request['extra'], content
    expectation_results = run_expectations! config, request['expectations'], content

    response = {exit: test_results[1], out: test_results[0], expectationResults: expectation_results}
    response[:feedback] = test_results[2] if not test_results[2].nil?

    response
  rescue Exception => e
    {exit: :failed, out: "#{e.message}:\n#{e.backtrace.join("\n")}"}
  end


  def run_tests!(config, test, extra, content)
    compiler = TestCompiler.new(config)
    runner = TestRunner.new(config)

    file = compiler.create_compilation_file!(test, extra, content)
    runner.run_test_file!(file)
  ensure
    file.unlink if file
  end

  def run_expectations!(config, expectations, content)
    expectations_runner = ExpectationsRunner.new(config)

    if expectations
      expectations_runner.run_expectations!(expectations, content)
    else
      []
    end
  end
end
