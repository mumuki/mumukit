module Mumukit
  module WithEmbeddedEnvironment
    extend ActiveSupport::Concern
    included do
      include Mumukit::WithCommandLine
    end

    def run_test_file!(file)
      run_command run_test_command(file.path)
    end
  end
end
