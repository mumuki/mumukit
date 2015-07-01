module Mumukit
  module WithCommandLine
    SIGINT = 2
    SIGSEGV = 11
    SIGXCPU = 24

    def command_size_limit
      1024
    end

    def command_time_limit
      4
    end

    def limit_command
      MUMUKIT_LIMIT_SCRIPT
    end

    def run_command(command)
      out = %x{#{limit_command} #{command_size_limit} #{command_time_limit} $(cat <<EOLIMIT
#{command}
EOLIMIT
)}
      case $?.exitstatus
        when 0 then [out, :passed]
        when signal_status(SIGINT)  then [I18n.t('mumukit.memory_exceeded'), :aborted]
        when signal_status(SIGSEGV) then [I18n.t('mumukit.memory_exceeded'), :aborted]
        when signal_status(SIGXCPU) then [I18n.t('mumukit.time_exceeded', limit: command_time_limit), :aborted]
        else [out, :failed]
      end
    end

    def signal_status(signal)
      # see http://tldp.org/LDP/abs/html/exitcodes.html
      128 + signal
    end

  end
end
