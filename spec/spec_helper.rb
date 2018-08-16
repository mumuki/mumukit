require 'rspec'
require 'simplecov'
SimpleCov.start

require 'rspec'
require_relative '../lib/mumukit'

Mumukit.runner_name = 'demo'

RSpec.configure do |config|
  config.before(:each) do
    Mumukit.runtime.reset!
    Mumukit.reconfigure do |c|
      c.docker_image = 'alpine'
    end
  end
end

require_relative '../lib/mumukit/server/app'

def drop_hook(hook_class)
  Object.send :remove_const, hook_class.name.to_sym
end

def req(hash)
  OpenStruct.new hash
end
