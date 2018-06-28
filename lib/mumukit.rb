require 'mumukit/core'
require 'mumukit/directives'
require 'mumukit/content_type'
require 'ostruct'

I18n.load_translations_path File.join(__dir__, 'locales', '*.yml')

module Mumukit
end

require_relative 'mumukit/with_content_type'
require_relative 'mumukit/runner'
require_relative 'mumukit/version'
require_relative 'mumukit/env'
require_relative 'mumukit/cookie'
require_relative 'mumukit/with_tempfile'
require_relative 'mumukit/with_command_line'
require_relative 'mumukit/hook'
require_relative 'mumukit/defaults'
require_relative 'mumukit/runtime'
require_relative 'mumukit/isolated_environment'
require_relative 'mumukit/templates'
require_relative 'mumukit/request_validation_error'
require_relative 'mumukit/compilation_error'
require_relative 'mumukit/metatest'
require_relative 'mumukit/explainer'
require_relative 'mumukit/server'
