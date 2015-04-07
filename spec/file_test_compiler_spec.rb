require 'rspec'
require_relative '../lib/mumukit/file_test_compiler'

describe Mumukit::FileTestCompiler do
  include Mumukit::FileTestCompiler

  def compile(test, extra, content)
    test + extra + content
  end

  describe '#create_compilation_file!' do
    let(:file) { create_compilation_file!('foo', 'extra', 'bar') }

    it { expect(File.exists? file.path).to be true }
    it { expect(File.read(file.path)).to eq 'fooextrabar' }
  end
end

