module Mumukit
  module WithCommandLine
    def command_size_limit
      1024
    end

    def command_time_limit
      4
    end

    def run_command(command)
      out = %x{limit #{command_size_limit} #{command_time_limit} #{command}}
      case $?.exitstatus
        when 0 then [out, :passed]
        when 152 then ["Time exceeded #{command_time_limit}", :failed]
        when 130..139 then ['Memory exceeded', :failed]
        else [out, :failed]
      end
    end
  end
end
