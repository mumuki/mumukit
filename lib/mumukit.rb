require 'i18n'
require 'i18n/backend/fallbacks'
require 'active_support/all'

pwd = File.expand_path(File.dirname(__FILE__))

I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.load_path += Dir[File.join(pwd, 'locales', '*.yml')]

I18n.backend.load_translations

module Mumukit
end


require_relative 'mumukit/version'
require_relative 'mumukit/content_type'
require_relative 'mumukit/stub'
require_relative 'mumukit/with_tempfile'
require_relative 'mumukit/with_command_line'
require_relative 'mumukit/test_compiler/file_test_compiler'
require_relative 'mumukit/test_runner/file_test_runner'

require_relative 'stubs/expectations_runner'
require_relative 'stubs/feedback_runner'

require_relative 'mumukit/server/test_server'
require_relative 'mumukit/server/test_server_app'
