require 'yaml'
require 'ostruct'

class Mumukit::Server::TestServer

  include Mumukit::WithContentType

  def runtime
    Mumukit.runtime
  end

  def info(url)
    runtime.info.merge(runtime.metadata_hook.metadata).merge(url: url)
  end

  def start_request!(_request)
  end

  def parse_request(sinatra_request)
    OpenStruct.new parse_request_headers(sinatra_request).merge(parse_request_body(sinatra_request))
  end

  def parse_request_headers(sinatra_request)
    {}
  end

  def parse_request_body(sinatra_request)
    JSON.parse(sinatra_request.body.read).tap do |it|
      I18n.locale = it['locale'] || :en
    end rescue {}
  end

  def test!(request)
    respond_to(request) do |r|
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

  def query!(request)
    respond_to(request) do |r|
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

  def spec_structure
    runtime.metadata_hook.spec_structure
  end

  private

  def compile_and_run(hook, request)
    compilation = hook.compile(preprocess request)
    hook.run!(compilation)
  end

  def preprocess(request)
    if Mumukit.config.preprocessor_enabled
      directives_pipeline.transform(request)
    else
      request
    end
  end

  def directives_pipeline
    @pipeline ||= Mumukit::Directives::Pipeline.new(
        [Mumukit::Directives::Sections.new,
         Mumukit::Directives::Interpolations.new('test'),
         Mumukit::Directives::Interpolations.new('extra'),
         Mumukit::Directives::Flags.new],
        Mumukit.config.comment_type)
  end

  def validate_request!(request)
    runtime.validation_hook.validate! request
  end

  def respond_to(request)
    yield request.tap { |r| validate_request! r }
  rescue Mumukit::RequestValidationError => e
    {exit: :aborted, out: e.message}
  rescue Exception => e
    {exit: :errored, out: content_type.format_exception(e)}
  end

end
