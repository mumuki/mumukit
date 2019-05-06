module Mumukit
  class ErrorPattern
    def initialize(regexp)
      @regexp = regexp
    end

    def matches?(result)
      @regexp.matches? result
    end

    def sanitize(result)
      result.gsub(@regexp, '').strip
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