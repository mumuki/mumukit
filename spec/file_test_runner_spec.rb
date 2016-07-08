require 'spec_helper'

class BaseTestRunner < Mumukit::Templates::FileHook
  def command_line(path)
    "cat #{path}"
  end
end

class EmbeddedEnvTestRunner < BaseTestRunner
  isolated false
end

class IsolatedEnvTestRunner < BaseTestRunner
  isolated true
end

describe Mumukit::Templates::FileHook do
  context 'with embedded env' do
    let(:runner) { EmbeddedEnvTestRunner.new }

    it { expect(runner.run!(File.new 'spec/data/data.txt')).to eq ["lorem impsum", :passed] }
  end

  context 'with isolated env' do
    let(:runner) { IsolatedEnvTestRunner.new }

    it { expect(runner.run!(File.new 'spec/data/data.txt')).to eq ["lorem impsum\n", :passed] }
  end
end

describe Mumukit::Runtime do
  let(:runtime) { Mumukit::Runtime.new({}) }

  context 'when test runner is isolated' do
    before do
      class DemoTestHook < IsolatedEnvTestRunner
      end
    end

    after do
      drop_hook DemoTestHook
    end

    it { expect(runtime.test_hook?).to be true }
    it { expect(runtime.info[:features][:sandboxed]).to be true }
  end

  context 'when test runner is embedded' do
    before do
      class DemoTestHook < EmbeddedEnvTestRunner
      end
    end

    after do
      drop_hook DemoTestHook
    end

    it { expect(runtime.info[:features][:sandboxed]).to be false }
  end
end