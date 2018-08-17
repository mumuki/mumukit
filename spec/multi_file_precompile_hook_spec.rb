require_relative './spec_helper.rb'

describe Mumukit::Templates::MultiFilePrecompileHook do

  class SomeMultiFilePrecompileHook < Mumukit::Templates::MultiFilePrecompileHook
    def main_file
      'main.js'
    end

    def consolidate(main_content, files)
      main_content.gsub(/(import\(\"([\w\.]+)\"\);)/) { files[$2] }
    end
  end

  let(:content) { SomeMultiFilePrecompileHook.new.compile(request).content }

  context 'multifile disabled' do
    let(:request) { req content: "foobar" }
    it { expect { content }.to raise_error 'You need to enable Mumukit.config.multifile first!' }
  end

  context 'multifile enabled' do
    before do
      Mumukit.configure do |config|
        config.multifile = true
      end
    end

    context 'no file request' do
      let(:request) { req content: "foobar" }
      it { expect(content).to eq 'foobar' }
    end

    context 'single file request' do
      let(:content) { SomeMultiFilePrecompileHook.new.compile(request).content }
      let(:request) { req content: { "anotherFile.js" => 'alert("WORLD");' } }

      it { expect(content).to eq 'alert("WORLD");' }
    end

    context 'multifile request' do
      let(:content) { SomeMultiFilePrecompileHook.new.compile(request).content }
      let(:request) {
        req content: {
            "main.js" => 'console.log("hello");   import("anotherFile.js");   console.log("!!");',
            "anotherFile.js" => 'alert("WORLD");'
        }
      }

      it { expect(content).to eq 'console.log("hello");   alert("WORLD");   console.log("!!");' }
    end
  end
end
