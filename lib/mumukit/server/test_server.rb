require 'yaml'
require 'ostruct'

class Mumukit::TestServer
  attr_reader :runtime

  include Mumukit::WithContentType

  def initialize(runtime_config=nil)
    @runtime = Mumukit::Runtime.new(runtime_config)
  end

  def info(path)
    runtime.info.merge(runtime.metadata_publisher.metadata).merge(url: path)
  end

  def test!(raw_request)
    respond_to(raw_request) do |r|
      test_results = run_tests! r
      expectation_results = run_expectations! r

      results = OpenStruct.new(test_results: test_results,
                               expectation_results: expectation_results)

      feedback = run_feedback! r, results

      Mumukit::ResponseBuilder.build do
        add_test_results(test_results)
        add_expectation_results(expectation_results)
        add_feedback(feedback)
      end
    end
  end

  def query!(raw_request)
    respond_to(raw_request) do |r|
      results = run_query!(r)
      Mumukit::ResponseBuilder.build do
        add_query_results(results)
      end
    end
  end

  def run_query!(request)
    runtime.query_runner.run_query! request
  end

  def run_tests!(request)
    return ['', :passed] if request.test.blank?

    compilation = runtime.test_compiler.create_compilation!(request)
    runtime.test_runner.run_compilation!(compilation)
  end

  def run_expectations!(request)
    request.expectations ? runtime.expectations_runner.run_expectations!(request) : []
  end

  def run_feedback!(request, results)
    runtime.feedback_runner.run_feedback!(request, results)
  end

  private

  def parse_request(request)
    OpenStruct.new(request).tap { |r| validate_request! r }
  end

  def validate_request!(request)
    runtime.request_validator.validate! request
  end


  def respond_to(raw_request)
    yield parse_request(raw_request)
  rescue Mumukit::RequestValidationError => e
    {exit: :aborted, out: e.message}
  rescue Exception => e
    {exit: :errored, out: content_type.format_exception(e)}
  end
end
