module Mumukit
  module WithIsolatedEnvironment
    def run_file!(file)
      env = Mumukit::IsolatedEnvironment.new
      env.configure!(file) { |filename| command_line(filename) }
      env.run!
    ensure
      env.destroy!
    end
  end
end