module Mumukit::Metatest
  class Aborted < StandardError
  end

  class Errored < StandardError
  end

  class Failed < StandardError
  end
end