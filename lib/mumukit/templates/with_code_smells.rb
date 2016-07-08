module Mumukit
  module Templates::WithCodeSmells
    def parse_response(response)
      super + response['smells'].map { |it| {expectation: parse_expectation(it), result: false} }
    end
  end
end
