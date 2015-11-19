module Mumukit
  class MashupTestCompiler < FileTestCompiler
    def compile(request)
      <<EOF
#{request.extra}
#{request.content}
#{request.test}
EOF
    end
  end
end
