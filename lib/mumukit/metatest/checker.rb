module Mumukit::Metatest
  class Checker
    def check(result, example)
      check_assertions result, example[:postconditions], example
      [example[:name], :passed, render_success_output(result)]
    rescue => e
      [example[:name], :failed, render_error_output(result, e.message)]
    end

    def render_success_output(value)
      nil
    end

    def render_error_output(value, error)
      error
    end

    def check_assertions(result, assertions_hash, example)
      assertions_hash.each do |assertion_name, assertion_config|
        check_assertion assertion_name, result, assertion_config, example
      end
    end

    def check_assertion(assertion_name, result, assertion_config, _example)
      send "check_#{assertion_name}", result, assertion_config
    end

    def fail(message)
      raise Mumukit::Metatest::Failed, message
    end

    def abort(message)
      raise Mumukit::Metatest::Aborted, message
    end

    def error(message)
      raise Mumukit::Metatest::Errored, message
    end
  end
end
