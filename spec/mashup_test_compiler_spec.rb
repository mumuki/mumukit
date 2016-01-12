require_relative './spec_helper'
require 'ostruct'

describe Mumukit::WithMashupFileContent do
  def req(test, extra, content)
    OpenStruct.new(test:test, extra:extra, content: content)
  end

  true_test = <<EOT
describe '_true' do
  it 'is true' do
    expect(_true).to be true
  end
end
EOT

  true_submission = <<EOT
_true  = true
EOT

  compiled_test_submission = <<EOT
_false = false
_true  = true

describe '_true' do
  it 'is true' do
    expect(_true).to be true
  end
end

EOT

  class SampleMashupTestHook < Mumukit::FileTestHook
    include Mumukit::WithMashupFileContent
  end

  describe '#compile' do
    let(:compiler) { SampleMashupTestHook.new(nil) }
    it { expect(compiler.compile_file_content(req(true_test, '_false = false', true_submission))).to eq(compiled_test_submission) }
  end

end
