module Mumukit
  module Templates::WithEmbeddedEnvironment
    extend ActiveSupport::Concern
    included do
      include Mumukit::WithCommandLine
    end

    def run_files!(*files)
      run_command command_line(*files.map {|f| f.path})
    end

    alias_method 'run_file!', 'run_files!'
  end
end
