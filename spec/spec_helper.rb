require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rspec'
require_relative '../lib/mumukit'

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.load_path = Dir['locales/*.yml']
I18n.backend.load_translations
