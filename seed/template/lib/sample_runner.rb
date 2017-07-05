require 'mumukit'

Mumukit.runner_name = '<RUNNER>'
Mumukit.configure do |config|
  config.docker_image = 'mumuki/mumuki-<RUNNER>-worker'
end

require_relative './version_hook'
require_relative './metadata_hook'
require_relative './test_hook'
