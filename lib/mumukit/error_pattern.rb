module Mumukit
  class ErrorPattern
    def initialize(regexp, status: :failed, replace: '')
      @regexp = regexp
      @status = status
      @replacement = replace
    end

    def matches?(result, status)
      @status.like?(status) && @regexp.match?(result)
    end

    def sanitize(result)
      result.gsub(@regexp, @replacement).strip
    end

    def transform(result, status)
      [sanitize(result), status]
    end

    class Errored < ErrorPattern
      def transform(result, _status)
        super(result, :errored)
      end
    end

    class Failed < ErrorPattern
      def transform(result, _status)
        super(result, :failed)
      end
    end
  end
end
