module Mumukit::Metatest
  class Checker
    def check(value, example)
      example[:postconditions].each { |key, arg| check_assertion key, value, arg, example }
      [example[:name], :passed, render_success_output(value)]
    rescue => e
      [example[:name], :failed, render_error_output(value, e.message)]
    end

    def render_success_output(value)
      nil
    end

    def render_error_output(value, error)
      error
    end

    def check_assertion(key, value, arg, example)
      send "check_#{key}", value, arg
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