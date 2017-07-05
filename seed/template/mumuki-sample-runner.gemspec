# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version_hook'


Gem::Specification.new do |spec|
  spec.name          = 'mumuki-<RUNNER>-runner'
  spec.version       = <CONSTANT>VersionHook::VERSION
  spec.authors       = ['<AUTHOR>']
  spec.summary       = '<RUNNER> Runner for Mumuki'
  spec.homepage      = 'http://github.com/<USER>/mumuki-<RUNNER>-server'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/**']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'mumukit', '~> 2.6'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'mumukit-bridge', '~> 1.3'
end



