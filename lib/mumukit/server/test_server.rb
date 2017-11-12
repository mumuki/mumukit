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
      pipeline = Mumukit::Server::TestPipeline.new self, r
      pipeline.evaluate!
      pipeline.generate_feedback!
      pipeline.response
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

  def try!(request)
    respond_to(request) do |r|
      results = run_try!(r)
      Mumukit::Server::ResponseBuilder.build do
        add_try_results(results)
      end
    end
  end

  def run_tests!(request)
    return ['', :passed] if request.test.blank?

    compile_and_run runtime.test_hook, request
  end

  def run_expectations!(request)
    return [] if request.expectations.nil? || request.content.nil?

    compile_and_run runtime.expectations_hook, request
  end

  def run_feedback!(request, results)
    runtime.feedback_hook.run!(request, results)
  end

  private

  def run_query!(request)
    compile_and_run runtime.query_hook, request
  end

  def run_try!(request)
    compile_and_run runtime.try_hook, request
  end

  def compile_and_run(hook, request)
    compilation = hook.compile(request)
    hook.run!(compilation)
  rescue Mumukit::CompilationError => e
    [e.message, :errored]
  end

  def preprocess(request)
    Mumukit.directives_pipeline.transform(request)
  end

  def validate_request!(request)
    runtime.validation_hook.validate! request
  end

  def respond_to(request)
    yield preprocess request.tap { |r| validate_request! r }
  rescue Mumukit::RequestValidationError => e
    {exit: :aborted, out: e.message}
  rescue Exception => e
    {exit: :errored, out: content_type.format_exception(e)}
  end

end
