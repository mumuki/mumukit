require 'yaml'
require 'ostruct'

class Mumukit::TestServer < Mumukit::Stub
  def run!(request)
    r = OpenStruct.new(request)

    test_results = run_tests! r
    expectation_results = run_expectations! r

    results = OpenStruct.new(test_results: test_results,
                             expectation_results: expectation_results)

    feedback = run_feedback! r, results

    response = base_response(test_results)
    response.merge!(expectationResults: expectation_results) if expectation_results.present?
    response.merge!(feedback: feedback) if feedback.present?
    response
  rescue Exception => e
    {exit: :errored, out: content_type.format_exception(e)}
  end

  def base_response(test_results)
    {exit: test_results[1],
     out: test_results[0]}
  end

  def run_tests!(request)
    compiler = TestCompiler.new(config)
    runner = TestRunner.new(config)

    compilation = compiler.create_compilation!(request)
    runner.run_compilation!(compilation)
  end

  def run_expectations!(request)
    expectations_runner = ExpectationsRunner.new(config)

    request.expectations ? expectations_runner.run_expectations!(request) : []
  end

  def run_feedback!(request, results)
    FeedbackRunner.new(config).run_feedback!(request, results)
  end

end
