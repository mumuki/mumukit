
module Mumukit
  module Env
    def self.env
      Thread.current[:mumukit_env]
    end

    def self.env=(env)
      Thread.current[:mumukit_env] = env
    end

    def self.base_url
      rack_request.base_url
    end

    def self.rack_request
      Rack::Request.new(env)
    end
  end
end
