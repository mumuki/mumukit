class Mumukit::Server::ResponseBuilder

  def add_test_results(r)
    @response = base_response(r)
  end

  def add_query_results(r)
    @response = unstructured_base_response(r)
  end

  def add_expectation_results(r)
    @response.merge!(expectationResults: r) if r.present?
  end

  def add_try_results(r)
    @response = unstructured_base_response(r)
    @response.merge!(queryResult: r[2])
  end

  def add_feedback(f)
    @response.merge!(feedback: f) if f.present?
  end

  def build
    @response
  end

  def self.build(&block)
    builder = new
    builder.instance_eval(&block)
    builder.build
  end

  private

  def base_response(test_results)
    if structured_test_result?(test_results)
      structured_base_response(test_results)
    elsif unstructured_test_result?(test_results)
      unstructured_base_response(test_results)
    elsif mixed_test_result?(test_results)
      mixed_base_response(test_results)
    else
      raise "Invalid test results format: #{test_results}. You must either return [results_array], [results_string, status], or [results_array, results_string, status]"
    end
  end

  def structured_test_result?(test_results)
    test_results.size == 1 && test_results[0].is_a?(Array)
  end

  def unstructured_test_result?(test_results)
    test_results.size == 2 && test_results[0].is_a?(String)
  end

  def mixed_test_result?(test_results)
    test_results.size == 3 && test_results[0].is_a?(Array) && test_results[1].is_a?(String)
  end

  def structured_base_response(test_results)
    {testResults: test_results[0].map { |title, status, result|
      {title: title,
       status: status,
       result: result} }}
  end

  def unstructured_base_response(test_results)
    {exit: test_results[1],
     out: test_results[0]}
  end

  def mixed_base_response(test_results)
    structured_base_response(test_results).merge out: test_results[1], exit: test_results[2]
  end
end
