module Mumukit
  module Env
    def self.env
      Thread.current[:mumukit_env]
    end

    def self.env=(env)
      Thread.current[:mumukit_env] = env
    end
  end
end