require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rspec'
require_relative '../lib/mumukit'

def drop_hook(hook_class)
  Object.send :remove_const, hook_class.name.to_sym
end

def req(hash)
  OpenStruct.new hash
end

Mumukit.runner_name = 'demo'
Mumukit.configure do |c|
  c.docker_image = 'ubuntu'
end

class File
  def unlink
  end
end