# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mumukit/version'

Gem::Specification.new do |spec|
  spec.name          = 'mumukit'
  spec.version       = Mumukit::VERSION
  spec.authors       = ['Franco Leonardo Bulgarelli']
  spec.email         = ['flbulgarelli@yahoo.com.ar']
  spec.summary       = 'Mumuki Test Server Development Kit'
  spec.description   = 'Helpers for building a Mumuki Test Server'
  spec.homepage      = 'https://github.com/flbulgarelli/mumukit'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*', 'bin/**/*']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib', 'bin']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'rack-test'

  spec.add_dependency 'sinatra', '~> 2.0'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'i18n', '~> 0.7'
  spec.add_dependency 'puma'
  spec.add_dependency 'docker-api', '~> 1.22.2'
  spec.add_dependency 'excon', '~> 0.71'


  spec.add_dependency 'sinatra-cross_origin', '~> 0.4'
  spec.add_dependency 'mime-types', '~> 3.2'

  spec.add_dependency 'mulang', '~> 6.0'
  spec.add_dependency 'mumukit-inspection', '~> 5.0'

  spec.add_dependency 'mumukit-core', '~> 1.3'
  spec.add_dependency 'mumukit-directives', '~> 0.4'
  spec.add_dependency 'mumukit-content-type', '~> 1.10'
end
