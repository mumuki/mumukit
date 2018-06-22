class Mumukit::Runner::TestPipeline
  def initialize(runner, request)
    @runner = runner
    @request = request
  end

  def evaluate!
    @test_results = @runner.run_test_hook! @request
    @expectation_results = @runner.run_expectations_hook!(@request).try do |raw|
      static_errors?(raw) ? [] : raw
    end
  end

  def generate_feedback!
    @feedback = @runner.run_feedback_hook! @request, struct(test_results: @test_results, expectation_results: @expectation_results)
  end

  def prepare_response!(builder)
    builder.add_test_results @test_results
    builder.add_expectation_results @expectation_results
    builder.add_feedback @feedback
  end

  def static_errors?(raw)
    raw.size == 2 && raw[1] == :errored
  end
end
