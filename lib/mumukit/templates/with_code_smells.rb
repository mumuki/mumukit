module Mumukit
  module Templates::WithCodeSmells
    def make_response(mulang_response)
      mulang_response['results'] + mulang_response['smells'].map { |it| { 'expectation' => it, 'result' => false } }
    end
  end
end
