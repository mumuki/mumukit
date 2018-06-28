require 'spec_helper'

class BaseTestRunner < Mumukit::Templates::FileHook
  def initialize
    super(struct docker_image: 'alpine')
  end

  def command_line(path)
    "cat #{path}"
  end

  def post_process_file(file, result, status)
    super(file, result.strip, status)
  end
end

class EmbeddedEnvTestRunner < BaseTestRunner
  isolated false
end

class IsolatedEnvTestRunner < BaseTestRunner
  isolated true
end

class MetatestTestRunner < BaseTestRunner
  isolated false
  metatested true

  def metatest_checker
    CrazyChecker.new
  end

  class CrazyChecker < Mumukit::Metatest::Checker
    def check_eq(compilation, arg)
      fail "expected '#{compilation[:outputs]}' to equal '#{arg}'" unless compilation[:outputs] == arg
    end
  end
end

describe Mumukit::Templates::FileHook do
  context 'with metatest runner' do
    let(:runner) { MetatestTestRunner.new }

    before do
      runner.instance_variable_set :@examples, [{name: 'array test', postconditions: {eq: [1, 2, 3]}}]
    end

    it { expect(runner.run!(File.new 'spec/data/metatest.json')).to eq [[["array test", :failed, "expected '[1, 2, 4]' to equal '[1, 2, 3]'"]]]}
  end
end

describe Mumukit::Templates::FileHook do
  context 'with line number offset' do
    let(:runner) { MetatestTestRunner.new }

    before do
      runner.instance_variable_set :@examples, [{name: 'array test', postconditions: {eq: [1, 2, 3]}}]
    end

    it { expect(runner.run!(File.new 'spec/data/metatest.json')).to eq [[["array test", :failed, "expected '[1, 2, 4]' to equal '[1, 2, 3]'"]]]}
  end
end

describe Mumukit::Templates::FileHook do
  context 'with embedded env' do
    let(:runner) { EmbeddedEnvTestRunner.new }

    it { expect(runner.run!(File.new 'spec/data/data.txt')).to eq ["lorem impsum", :passed] }
  end

  context 'with isolated env' do
    let(:runner) { IsolatedEnvTestRunner.new }

    it { expect(runner.run!(File.new 'spec/data/data.txt')).to eq ["lorem impsum", :passed] }
  end
end

describe Mumukit::Runtime do
  let(:runtime) { Mumukit::Runtime.new(hooks: hooks) }

  context 'when test runner is isolated' do
    let(:hooks) { { test: Class.new(IsolatedEnvTestRunner) } }

    it { expect(runtime.hook_defined?(:test)).to be true }
    it { expect(runtime.info[:features][:sandboxed]).to be true }
  end

  context 'when test runner is embedded' do
    let(:hooks) { { test: Class.new(EmbeddedEnvTestRunner) } }

    it { expect(runtime.info[:features][:sandboxed]).to be false }
  end
end
