class Mumukit::Runner
end

require_relative './runner/pipeline'
require_relative './runner/compilation'
require_relative './runner/hooks'
require_relative './runner/response_builder'
require_relative './runner/test_pipeline'

class Mumukit::Runner
  include Mumukit::Runner::Pipeline
  include Mumukit::Runner::Compilation
  include Mumukit::Runner::Hooks
  include Mumukit::WithContentType

  attr_reader :runtime

  def initialize(runtime)
    @runtime = runtime
  end

  def info
    runtime.info.merge(runtime.new_hook(:metadata).metadata)
  end

  def run_test!(request)
    respond_to(request) do |r, response_builder|
      pipeline = Mumukit::Runner::TestPipeline.new self, r
      pipeline.evaluate!
      pipeline.generate_feedback!
      pipeline.prepare_response! response_builder
    end
  end

  def run_query!(request)
    respond_to(request) do |r, response_builder|
      results = run_query_hook!(r)
      response_builder.add_query_results(results)
    end
  end

  def run_try!(request)
    respond_to(request) do |r, response_builder|
      results = run_try_hook!(r)
      response_builder.add_try_results(results)
    end
  end

  def prefix
    name.camelize
  end

  def self.create(settings={})
    new(Mumukit::Runtime.new(settings))
  end

  private

  def respond_to(request)
    run_validation_hook! request
    response_builder = Mumukit::Runner::ResponseBuilder.new
    yield run_precompile_hook(request), response_builder
    response_builder.build
  rescue Mumukit::RequestValidationError => e
    {exit: :aborted, out: e.message}
  rescue => e
    {exit: :errored, out: content_type.format_exception(e)}
  end

  def config
    runtime.config
  end
end
