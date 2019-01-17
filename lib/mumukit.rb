require 'mumukit/core'
require 'mumukit/directives'
require 'ostruct'

I18n.load_translations_path File.join(__dir__, 'locales', '*.yml')

module Mumukit
  def self.current_runner=(runner)
    @current_runner = runner
  end

  def self.current_runner
    raise "no runner selected. Did you forget to set current runner's name?" unless @current_runner
    @current_runner
  end

  def self.runner_name=(name)
    self.current_runner = Mumukit::Runner.new(name)
  end

  def self.runner_name
    current_runner.name
  end

  def self.runner_url
    Rack::Request.new(Mumukit::Env.env).base_url
  end

  def self.configure_defaults(&block)
    Mumukit::Runner.configure_defaults(&block)
  end

  class << self
    delegate :prefix, :config, :configure, :reconfigure, :runtime, :configure_runtime, :directives_pipeline, to: :current_runner
  end
end

require_relative 'mumukit/runner'

Mumukit.configure_defaults do |config|
  config.limit_script = File.join(__dir__, '..', 'bin', 'limit')
  config.content_type = :plain
  config.comment_type = Mumukit::Directives::CommentType::Cpp
  config.preprocessor_enabled = true
  config.structured = false
  config.stateful = false
  config.command_time_limit = 4
  config.command_size_limit = 1024
  config.process_expectations_on_empty_content = false
  config.run_test_hook_on_empty_test = false
  config.multifile = false
end

require 'mumukit/content_type'

require_relative 'mumukit/utils/named_tempfile'
require_relative 'mumukit/version'
require_relative 'mumukit/env'
require_relative 'mumukit/cookie'
require_relative 'mumukit/with_tempfile'
require_relative 'mumukit/with_content_type'
require_relative 'mumukit/with_command_line'
require_relative 'mumukit/hook'
require_relative 'mumukit/runtime'
require_relative 'mumukit/isolated_environment'
require_relative 'mumukit/templates'
require_relative 'mumukit/request_validation_error'
require_relative 'mumukit/compilation_error'
require_relative 'mumukit/defaults'
require_relative 'mumukit/metatest'
require_relative 'mumukit/explainer'
require_relative 'mumukit/server'