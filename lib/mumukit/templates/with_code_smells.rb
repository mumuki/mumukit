module Mumukit
  module Templates::WithCodeSmells
    def make_response(mulang_output)
      mulang_output['results'] + mulang_output['smells'].map { |it| { 'expectation' => it, 'result' => false } }
    end
  end
end
