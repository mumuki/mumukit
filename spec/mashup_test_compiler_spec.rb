require_relative './spec_helper'
require 'ostruct'


class SampleMashupTestHook < Mumukit::Templates::FileHook
  mashup
end


class SampleMashupWithFieldsTestHook < Mumukit::Templates::FileHook
  mashup :content
end


describe Mumukit::Templates::WithMashupFileContent do
  def req(test, extra, content)
    OpenStruct.new(test: test, extra: extra, content: content)
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

  describe '#compile' do
    context 'no fields' do
      let(:compiler) { SampleMashupTestHook.new(nil) }
      it { expect(compiler.compile_file_content(req(true_test, '_false = false', true_submission))).to eq(compiled_test_submission) }
    end
    context 'with fields' do
      let(:compiler) { SampleMashupWithFieldsTestHook.new(nil) }
      it { expect(compiler.compile_file_content(req(true_test, '_false = false', true_submission))).to eq(true_submission) }
    end
  end


end
