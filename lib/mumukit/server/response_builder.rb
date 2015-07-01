class Mumukit::ResponseBuilder

  def add_test_results(r)
    @response = base_response(r)
  end

  def add_expectation_results(r)
    @response.merge!(expectationResults: r) if r.present?
  end


  def add_feedback(f)
    @response.merge!(feedback: f) if f.present?
  end

  def build
    @response
  end

  private

  def base_response(test_results)
    if test_results.size == 1 && test_results[0].is_a?(Array)
      structured_base_response(test_results)
    elsif test_results.size == 2 && test_results[0].is_a?(String)
      unstructured_base_response(test_results)
    else
      raise "Invalid test results format: #{test_results}. You must either return [results_array] or [results_string, status]"
    end
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

end
