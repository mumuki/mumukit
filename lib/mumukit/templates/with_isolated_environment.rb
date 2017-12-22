module Mumukit
  module Templates::WithIsolatedEnvironment
    def run_file!(file, get_command_method = :command_line)
      env = Mumukit::IsolatedEnvironment.new
      env.configure!(file) { |filename| send get_command_method, filename }
      env.run!
    ensure
      env.destroy!
    end
  end
end