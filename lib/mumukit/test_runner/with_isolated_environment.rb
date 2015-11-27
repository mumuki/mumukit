module Mumukit
  module WithIsolatedEnvironment
    def run_test_file!(file)
      env = Mumukit::IsolatedEnvironment.new
      env.configure!(file) { |filename| run_test_command(filename) }
      env.run!
    ensure
      env.destroy!
    end
  end
end