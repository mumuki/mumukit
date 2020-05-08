module Mumukit::Metatest
  class Checker

    ## Check an input against a metatest example.
    ## The example has the following shape:
    ##
    ## ```
    ## {
    ##   name: 'an example name',
    ##   postconditions: {
    ##     an_assertion: assertion_config,
    ##     another_assertion: assertion_config,
    ##   }
    ## }
    ## ```
    ##
    ## Alternatively, the `postconditions` key may be omitted:
    ##
    ## ```
    ## {
    ##   name: 'an example name',
    ##   an_assertion: assertion_config,
    ##   another_assertion: assertion_config,
    ## }
    ##
    def check(input, example)
      check_assertions input, postconditions_for(example), example
      build_passed_test_result example, input
    rescue => e
      build_failed_test_result example, input, e
    end

    ## If no postconditions are included in the example,
    ## all the example except by the name is considered as postconditions
    def postconditions_for(example)
      example[:postconditions] || example.except(:name)
    end

    def render_success_output(value)
      nil
    end

    # Implementors should override this method if they want access to
    # the error details
    def render_error_output_with_details(value, error_message, _error_details)
      render_error_output value, error_message
    end

    # Implementors may override this method instead of `render_error_output_with_details`
    # if they don't want to handle error details.
    #
    # This method is only for backward compatibility. New code
    # should use `render_error_output_with_details`.
    def render_error_output(value, error_message)
      error_message
    end

    def check_assertions(input, assertions_hash, example)
      assertions_hash.each do |assertion_name, assertion_config|
        check_assertion assertion_name, input, assertion_config, example
      end
    end

    def check_assertion(assertion_name, input, assertion_config, _example)
      send "check_#{assertion_name}", input, assertion_config
    end

    def fail(message, details: nil)
      raise Mumukit::Metatest::Failed.new(message, details)
    end

    def abort(message, details: nil)
      raise Mumukit::Metatest::Aborted.new(message, details)
    end

    def error(message, details: nil)
      raise Mumukit::Metatest::Errored.new(message, details)
    end

    def build_passed_test_result(example, input)
      [example[:name], :passed, render_success_output(input)]
    end

    def build_failed_test_result(example, input, e)
      [example[:name], :failed, render_error_output_with_details(input, e.message, e.details)]
    end
  end
end
