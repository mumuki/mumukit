module Mumukit
  module Templates::WithIsolatedEnvironment
    def run_dir!(dir)
      env = Mumukit::IsolatedEnvironment.new
      env.configure!(dir) { |*filenames| command_line(*filenames) }
      env.run!
    ensure
      env.destroy!
    end
  end
end
