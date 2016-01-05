require 'spec_helper'

class BaseTestRunner < Mumukit::FileTestRunner
  def run_test_command(path)
    "cat #{path}"
  end
end

class EmbeddedEnvTestRunner < BaseTestRunner
  include Mumukit::WithEmbeddedEnvironment
end

class IsolatedEnvTestRunner < BaseTestRunner
  include Mumukit::WithIsolatedEnvironment
end

Mumukit.configure do |c|
  c.docker_image = 'ubuntu'
end

class File
  def unlink
  end
end


describe Mumukit::FileTestRunner do
  context 'with embedded env' do
    let(:runner) { EmbeddedEnvTestRunner.new }

    it { expect(runner.run_compilation!(File.new 'spec/data/data.txt')).to eq ["lorem impsum", :passed] }
  end

  context 'with isolated env' do
    let(:runner) { IsolatedEnvTestRunner.new }

    it { expect(runner.run_compilation!(File.new 'spec/data/data.txt')).to eq ["lorem impsum\n", :passed] }
  end
end

describe Mumukit::Runtime do
  let(:runtime) { Mumukit::Runtime.new({}) }

  context 'when test runner is isolated' do
    before do
      class TestRunner < IsolatedEnvTestRunner
      end
    end

    after do
      drop_hook TestRunner
    end

    it { expect(runtime.info[:features][:sandboxed]).to be true }
  end

  context 'when test runner is embedded' do
    before do
      class TestRunner < EmbeddedEnvTestRunner
      end
    end

    after do
      drop_hook TestRunner
    end

    it { expect(runtime.info[:features][:sandboxed]).to be false }
  end
end