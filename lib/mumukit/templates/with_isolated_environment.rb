module Mumukit
  module Templates::WithIsolatedEnvironment
    def run_files!(*files)
      env = Mumukit::IsolatedEnvironment.new
      env.configure!(*files) { |*filenames| command_line(*filenames) }
      env.run!
    ensure
      env.destroy!
    end

    alias_method 'run_file!', 'run_files!'
  end
end