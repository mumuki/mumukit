class ErrorPattern
  def initialize(regexp, &transform)
    @regexp = regexp
    @transform = transform || proc { |result, status| [result, status] }
  end

  def matches?(result)
    @regexp.matches? result
  end

  def sanitize(result)
    result.gsub(@regexp, '').strip
  end

  def transform(result, status)
    @transform.call sanitize(result), status
  end

  class Errored < ErrorPattern
    def initialize(regexp)
      super(regexp) { |result, status| [result, :errored] }
    end
  end

  class Failed < ErrorPattern
    def initialize(regexp)
      super(regexp) { |result, status| [result, :failed] }
    end
  end
end
