require 'yaml'
require 'ostruct'

class Mumukit::TestServer < Mumukit::Stub
  def run!(request)
    r = OpenStruct.new(request)

    test_results = run_tests! config, r
    expectation_results = run_expectations! config, r

    results = OpenStruct.new(test_results: test_results,
                             expectation_results: expectation_results)

    feedback = run_feedback! config, r, results


    {exit: test_results[1],
     out: test_results[0],
     expectationResults: expectation_results,
     feedback: feedback}
  rescue Exception => e
    {exit: :failed, out: format_exception(e)}
  end


  def run_tests!(config, request)
    compiler = TestCompiler.new(config)
    runner = TestRunner.new(config)

    compilation = compiler.create_compilation!(request)
    runner.run_compilation!(compilation)
  end

  def run_expectations!(config, request)
    expectations_runner = ExpectationsRunner.new(config)

    request.expectations ?  expectations_runner.run_expectations!(request) :  []
  end

  def run_feedback!(config, request, results)
    FeedbackRunner.new(config).run_feedback!(request, results)
  end

  private

  def format_exception(e)
    "#{content_type.title e.message}\n#{content_type.code e.backtrace.join("\n")}"
  end
end
