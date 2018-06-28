module Mumukit::Runner::Hooks
  def run_test_hook!(request)
    return ['<skipped>', :passed] if should_skip_tests?(request.test)

    compile_and_run! :test, request
  end

  def run_expectations_hook!(request)
    return [] if should_skip_expectations?(request)

    compile_and_run! :expectations, request
  end

  def run_feedback_hook!(request, results)
    runtime.new_hook(:feedback).run!(request, results)
  end

  def run_query_hook!(request)
    compile_and_run! :query, request
  end

  def run_try_hook!(request)
    compile_and_run! :try, request
  end

  def run_precompile_hook(request)
    runtime.new_hook(:precompile).compile directives_pipeline.transform(request)
  end

  def run_validation_hook!(request)
    runtime.new_hook(:validation).validate! request
  end

  private

  def should_skip_expectations?(request)
    request.expectations.nil? || (request.content.nil? && !config.process_expectations_on_empty_content)
  end

  def should_skip_tests?(tests)
    tests.blank? && !config.run_test_hook_on_empty_test
  end
end
