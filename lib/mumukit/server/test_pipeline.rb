class Mumukit::Server::TestPipeline
  def initialize(server, request)
    @server = server
    @request = request
  end

  def evaluate!
    @test_results = @server.run_tests! @request
    @expectation_results = @server.run_expectations!(@request).try do |raw|
      static_errors?(raw) ? [] : raw
    end
  end

  def generate_feedback!
    @feedback = @server.run_feedback! @request,
                                     struct(test_results: @test_results, expectation_results: @expectation_results)
  end

  def response
    builder = Mumukit::Server::ResponseBuilder.new
    builder.add_test_results @test_results
    builder.add_expectation_results @expectation_results
    builder.add_feedback @feedback
    builder.add_inline_errors @inline_errors
    builder.build
  end

  def static_errors?(raw)
    raw.size == 2 && raw[1] == :errored
  end
end
