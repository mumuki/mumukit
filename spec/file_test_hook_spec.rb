require 'spec_helper'

class BaseTestRunner < Mumukit::Templates::FileHook
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

def new_file(file_path)
  new_dir 'solution' => File.read(file_path)
end

def new_dir(files)
  runner.write_tempdir! files
end

describe Mumukit::Templates::FileHook do
  context 'with metatest runner' do
    let(:runner) { MetatestTestRunner.new }

    before do
      runner.instance_variable_set :@examples, [{name: 'array test', postconditions: {eq: [1, 2, 3]}}]
    end

    it { expect(runner.run!(new_file 'spec/data/metatest.json')).to eq [[["array test", :failed, "expected '[1, 2, 4]' to equal '[1, 2, 3]'"]]]}
  end
end

describe Mumukit::Templates::FileHook do
  context 'with line number offset' do
    let(:runner) { MetatestTestRunner.new }

    before do
      runner.instance_variable_set :@examples, [{name: 'array test', postconditions: {eq: [1, 2, 3]}}]
    end

    it { expect(runner.run!(new_file 'spec/data/metatest.json')).to eq [[["array test", :failed, "expected '[1, 2, 4]' to equal '[1, 2, 3]'"]]]}
  end
end

describe Mumukit::Templates::FileHook do
  context 'with embedded env' do
    let(:runner) { EmbeddedEnvTestRunner.new }

    it { expect(runner.run!(new_file 'spec/data/data.txt')).to eq ["lorem impsum", :passed] }
  end

  context 'with isolated env' do
    let(:runner) { IsolatedEnvTestRunner.new }

    it { expect(runner.run!(new_file 'spec/data/data.txt')).to eq ["lorem impsum", :passed] }
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
