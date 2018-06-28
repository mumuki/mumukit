require 'mumukit'

module Mumukit::<Constant>
end

require_relative './version_hook'
require_relative './metadata_hook'
require_relative './test_hook'

module Mumukit::<Constant>
  def create_runner(config={})
    Mumukit::Runner.create(
      config: {
        name: '<RUNNER>',
        docker_image: 'mumuki/mumuki-<RUNNER>-worker',
      }.merge(config),
      hooks: {
        metadata: Mumukit::<Constant>::MetadataHook,
        test: Mumukit::<Constant>::TestHook,
        version: Mumukit::<Constant>::VersionHook
      })
  end
end
