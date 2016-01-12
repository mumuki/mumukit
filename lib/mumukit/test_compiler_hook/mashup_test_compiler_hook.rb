module Mumukit
  class MashupTestCompilerHook < FileTestCompilerHook
    def compile(request)
      <<EOF
#{request.extra}
#{request.content}
#{request.test}
EOF
    end
  end
end
