module Mumukit
  module WithEmbeddedEnvironment
    extend Mumukit::WithCommandLine

    def run_test_file!(file)
      run_command run_test_command(file.path)
    end
  end
end
