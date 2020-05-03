module Mumukit::Metatest
  class BaseError < StandardError
    attr_reader :details
    def initialize(message = "", details = nil)
      super(message)
      @details = details
    end
  end
  class Aborted < BaseError
  end

  class Errored < BaseError
  end

  class Failed < BaseError
  end
end
