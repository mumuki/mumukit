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
      builder = Mumukit::Metatest::TestResultBuilder.new

      check_assertions input, postconditions_for(example), example
      build_passed_test_result builder, example, input
    rescue => e
      build_failed_test_result builder, example, input, e
    end

    ## If no postconditions are included in the example,
    ## all the example except by the name is considered as postconditions
    def postconditions_for(example)
      example[:postconditions] || example.except(:name)
    end

    # Implementors may override this method instead of `build_success_output`
    # if they don't want to handle error details.
    #
    # This method is only for backward compatibility. New code
    # should use `build_success_output`.
    def render_success_output(_input)
      nil
    end

    # Implementors may override this method instead of `build_error_output`
    # if they don't want to handle error details.
    #
    # This method is only for backward compatibility. New code
    # should use `build_error_output`.
    def render_error_output(_input, error_message)
      error_message
    end

    # Implementors should override this method if they want access to
    # the error details and produce more complex test results
    def build_success_output(builder, _example, input)
      builder.result = render_success_output input
    end

    # Implementors should override this method if they want access to
    # the error details and produce more complex test results
    def build_error_output(builder, _example, input, error)
      builder.result = render_error_output input, error.message
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

    def build_passed_test_result(builder, example, input)
      builder.title = example[:name]
      builder.status = :passed
      build_success_output builder, example, input
      builder.build
    end

    def build_failed_test_result(builder, example, input, e)
      builder.title = example[:name]
      builder.status = :failed
      build_error_output builder, example, input, e
      builder.build
    end
  end
end
