require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rspec'
require_relative '../lib/mumukit'

Mumukit.runner_name = 'demo'
Mumukit.configure do |c|
  c.docker_image = 'ubuntu'
end

require_relative '../lib/mumukit/server/app'

def drop_hook(hook_class)
  Object.send :remove_const, hook_class.name.to_sym
end

def req(hash)
  OpenStruct.new hash
end
