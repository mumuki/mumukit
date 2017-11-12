class Mumukit::Server::TestPipeline
  def initialize(server, request)
    @server = server
    @request = request
  end

  def evaluate!
    @test_results = @server.run_tests! @request
    @expectation_results = @server.run_expectations! @request
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
    builder.build
  end
end
