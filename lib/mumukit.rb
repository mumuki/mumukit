require 'i18n'
require 'i18n/backend/fallbacks'
require 'active_support/all'
require 'ostruct'

pwd = File.expand_path(File.dirname(__FILE__))

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.load_path += Dir[File.join(pwd, 'locales', '*.yml')]

I18n.backend.load_translations

module Mumukit
  def self.configure
    @config ||= OpenStruct.new
    yield @config
  end

  def self.config
    @config
  end
end

Mumukit.configure do |config|
  config.limit_script = File.join(pwd, '..', 'bin', 'limit')
  config.content_type = :plain
  config.structured = false
  config.mulang_path = 'mulang'
  config.command_time_limit = 4
  config.command_size_limit = 1024
end

require 'mumukit/content_type'

require_relative 'mumukit/with_tempfile'
require_relative 'mumukit/with_content_type'
require_relative 'mumukit/with_command_line'
require_relative 'mumukit/version'
require_relative 'mumukit/hook'
require_relative 'mumukit/runtime'
require_relative 'mumukit/isolated_environment'
require_relative 'mumukit/templates'
require_relative 'mumukit/request_validation_error'
require_relative 'mumukit/defaults'
require_relative 'mumukit/server'
