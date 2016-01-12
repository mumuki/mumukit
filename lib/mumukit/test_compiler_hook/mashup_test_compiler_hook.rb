module Mumukit
  class MashupTestCompilerHook < FileTestCompilerHook
    def compile_file_content(request)
      <<EOF
#{request.extra}
#{request.content}
#{request.test}
EOF
    end
  end
end
