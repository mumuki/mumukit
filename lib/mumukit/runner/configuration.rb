module Mumukit::Runner::Configuration
  extend ActiveSupport::Concern

  def configure
    @config ||= self.class.default_config.clone
    yield @config
  end

  def config
    @config or raise 'This runner has not being configured yet'
  end

  module ClassMethods
    def default_config
      @default_config
    end

    def configure_defaults
      @default_config ||= OpenStruct.new
      yield @default_config
    end
  end
end
