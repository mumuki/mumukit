module Mumukit
  module Env
    def self.env
      Thread.current[:mumukit_env]
    end

    def self.env=(env)
      Thread.current[:mumukit_env] = env
    end

    # A safe logger, which uses `rack_logger` if available
    # or `root_logger` otherwise
    def self.logger
      rack_logger || root_logger
    end

    # The rack env logger. `nil`` when no `env` is available
    #
    # Designed to be used during a request
    def self.rack_logger
      env&.[]('rack.logger')
    end

    # A logger to stdout. It must be used when no rack `env` is available.
    # Logs as INFO by default.
    #
    # Designed to be used during app initialization process
    def self.root_logger
      @logger ||= Logger.new(STDOUT).tap { |it| it.level = Logger::INFO }
    end
  end
end
