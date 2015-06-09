module Mumukit
  module WithCommandLine
    def command_size_limit
      1024
    end

    def command_time_limit
      4
    end

    def limit_command
      'limit'
    end

    def run_command(command)
      out = %x{#{limit_command} #{command_size_limit} #{command_time_limit} $(cat <<EOLIMIT
#{command}
EOLIMIT
)}
      case $?.exitstatus
        when 0 then [out, :passed]
        when 152 then ["Time exceeded #{command_time_limit}", :aborted]
        when 130..139 then ['Memory exceeded', :aborted]
        else [out, :failed]
      end
    end
  end
end
