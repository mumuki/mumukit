require_relative './spec_helper'

describe 'Env logger concern' do
  describe 'logger with missing env' do
    it { expect(Mumukit::Env.logger).to be Mumukit::Env.root_logger }
    it { expect(Mumukit::Env.logger.level).to be Logger::INFO }
  end

  describe 'rack logger with existing env' do
    before { Mumukit::Env.env = { 'rack.logger' => Rack::Logger.new('test') } }
    after { Mumukit::Env.env = nil }

    it { expect(Mumukit::Env.logger).to be Mumukit::Env.rack_logger }
  end
end

