module Mumukit
  module WithCommandLine
    def run_command(command)
      [%x{#{command}}, $?.success? ? :passed : :failed]
    end
  end
end
