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

  let(:request) {
    req "main.js": 'console.log("hello");   import("anotherFile.js");   console.log("!!");',
        "anotherFile.js": 'alert("WORLD");'
  }

  describe 'content consolidation' do
    let(:content) { SomeMultiFilePrecompileHook.new.compile(request).content }

    it { expect(content).to eq 'console.log("hello");   alert("WORLD");   console.log("!!");' }
  end
end