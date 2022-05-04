module Mumukit
  module Templates::WithEmbeddedEnvironment
    extend ActiveSupport::Concern
    included do
      include Mumukit::WithCommandLine
    end

    def run_dir!(dir)
      run_command command_line(*dir.files.map(&:path))
    end
  end
end
