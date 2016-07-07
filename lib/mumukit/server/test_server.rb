require 'yaml'
require 'ostruct'

class Mumukit::Server::TestServer
  attr_reader :runtime

  include Mumukit::WithContentType

  def initialize(runtime_config=nil)
    @runtime = Mumukit::Runtime.new(runtime_config)
  end

  def info(url)
    runtime.info.merge(runtime.metadata_hook.metadata).merge(url: url)
  end

  def start_request!(_raw_request)
  end

  def test!(raw_request)
    respond_to(raw_request) do |r|
      test_results = run_tests! r
      expectation_results = run_expectations! r

      results = OpenStruct.new(test_results: test_results,
                               expectation_results: expectation_results)

      feedback = run_feedback! r, results

      Mumukit::Server::ResponseBuilder.build do
        add_test_results(test_results)
        add_expectation_results(expectation_results)
        add_feedback(feedback)
      end
    end
  end

  def query!(raw_request)
    respond_to(raw_request) do |r|
      results = run_query!(r)
      Mumukit::Server::ResponseBuilder.build do
        add_query_results(results)
      end
    end
  end

  def run_query!(request)
    compile_and_run runtime.query_hook, request
  end

  def run_tests!(request)
    return ['', :passed] if request.test.blank?

    compile_and_run runtime.test_hook, request
  end

  def run_expectations!(request)
    if request.expectations
      compile_and_run runtime.expectations_hook, request
    else
      []
    end
  end

  def run_feedback!(request, results)
    runtime.feedback_hook.run!(request, results)
  end

  private

  def compile_and_run(hook, request)
    compilation = hook.compile(request)
    hook.run!(compilation)
  end

  def parse_request(request)
    OpenStruct.new(request)
  end

  def validate_request!(request)
    runtime.validation_hook.validate! request
  end

  def respond_to(raw_request)
    yield parse_request(raw_request).tap { |r| validate_request! r }
  rescue Mumukit::RequestValidationError => e
    {exit: :aborted, out: e.message}
  rescue Exception => e
    {exit: :errored, out: content_type.format_exception(e)}
  end
end
