require 'rspec'
require 'simplecov'
SimpleCov.start

require 'rspec'
require_relative '../lib/mumukit'
require_relative '../lib/mumukit/server'

def req(hash)
  OpenStruct.new hash
end
