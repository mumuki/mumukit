module Mumukit
  module Templates::WithIsolatedEnvironment
    def run_file!(file)
      env = Mumukit::IsolatedEnvironment.new(config)
      env.configure!(file) { |filename| command_line(filename) }
      env.run!
    ensure
      env.destroy!
    end
  end
end
