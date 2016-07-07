require 'i18n'
require 'i18n/backend/fallbacks'
require 'active_support/all'
require 'ostruct'

pwd = File.expand_path(File.dirname(__FILE__))

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.load_path += Dir[File.join(pwd, 'locales', '*.yml')]

I18n.backend.load_translations

module Mumukit
  def self.start_request(_request)
  end

  def self.current_runner=(runner)
    @current_runner = runner
  end

  def self.current_runner
    @current_runner
  end

  def self.runner_name=(name)
    self.current_runner = Mumukit::Runner.new(name)
  end

  def self.runner_name
    current_runner.name
  end

  def self.prefix
    current_runner.prefix
  end

  def self.configure(&block)
    current_runner.configure(&block)
  end

  def self.configure_defaults(&block)
    Mumukit::Runner.configure_defaults(&block)
  end

  def self.config
    current_runner.config
  end
end

require_relative 'mumukit/runner'

Mumukit.configure_defaults do |config|
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
