module Mumukit
  module WithEmbeddedEnvironment
    extend ActiveSupport::Concern
    included do
      include Mumukit::WithCommandLine
    end

    def run_file!(file)
      run_command command_line(file.path)
    end
  end
end
