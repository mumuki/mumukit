require_relative './spec_helper.rb'

class IntegrationTestBaseTestHook < Mumukit::Templates::FileHook
  def compile_file_content(r)
    "#{r.test}  #{r.extra}  #{r.content}"
  end
end


class EchoPathTestRunner < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '_test.txt'
  end

  def compile_file_content(*)
    ''
  end

  def command_line(path)
    "echo path is #{path}"
  end
end

class LineNumberTestRunner < Mumukit::Templates::FileHook
  isolated true
  line_number_offset 30, include_extra: true

  def tempfile_extension
    '_spec.rb'
  end

  def compile_file_content(*)
    ''
  end

  def command_line(path)
    "echo #{path}:65:in `load': #{path}:62: syntax error, unexpected tIDENTIFIER, expecting keyword_end (SyntaxError)"
  end
end

describe Mumukit::Server::TestServer do
  let(:server) { Mumukit::Server::TestServer.new }
  let(:result) { server.test!(request) }
  let(:request) { req content: 'foo', test: 'bar', expectations: [] }
  let(:info) { server.info('http://localhost:8080')[:features] }

  before { Mumukit.configure_runtime(nil) }

  context 'when there are not tests and no expectations' do
    it { expect(server.test!(req content: 'foo')).to eq out: '', exit: :passed }
  end


  describe 'filename hiding' do
    before do
      class DemoTestHook < EchoPathTestRunner
      end
    end
    after do
      drop_hook DemoTestHook
    end
    it { expect(result).to eq out: "path is solution_test.txt\n", exit: :passed }
  end

  describe 'with precompile hook' do
    before do
      class DemoTestHook < Mumukit::Defaults::TestHook
        def run!(request)
          [request.something, :passed]
        end
      end
      class DemoPrecompileHook < Mumukit::Hook
        def compile(request)
          struct request.to_h.merge(something: 'something precompiled')
        end
      end
    end
    after do
      drop_hook DemoTestHook
      drop_hook DemoPrecompileHook
    end
    it { expect(result).to eq out: "something precompiled", exit: :passed }
  end

  describe 'line number offset' do
    before do
      class DemoTestHook < LineNumberTestRunner
      end
    end
    after do
      drop_hook DemoTestHook
    end

    context 'no extra' do
      it { expect(result[:out])
            .to eq "solution_spec.rb:35:in `load': solution_spec.rb:32: syntax error, unexpected tIDENTIFIER, expecting keyword_end (SyntaxError)\n" }
    end

    context 'with extra' do
      let(:request) { req content: 'foo', test: 'bar', extra: "hello\nworld\n", expectations: [] }
      it { expect(result[:out])
            .to eq "solution_spec.rb:33:in `load': solution_spec.rb:30: syntax error, unexpected tIDENTIFIER, expecting keyword_end (SyntaxError)\n" }
    end
  end

  describe 'with multifile precompile hook' do
    let(:request) {
      req content: '
/*<main.js#*/
console.log("hello");
import("a-file.js");
import("another-file.js");
/*#main.js>*/

/*<a-file.js#*/
alert("world");
/*#a-file.js>*/

/*<another-file.js#*/
alert("!");
/*#another-file.js>*/'
    }
    before do
      class DemoTestHook < Mumukit::Defaults::TestHook
        def run!(request)
          [request.content, :passed]
        end
      end
      class DemoPrecompileHook < Mumukit::Templates::MultiFilePrecompileHook
        def main_file
          'main.js'
        end

        def consolidate(main_content, files)
          main_content.gsub(/(import\(\"([\w\.]+)\"\);)/) { files[$2] }
        end
      end
    end
    after do
      drop_hook DemoTestHook
      drop_hook DemoPrecompileHook
    end
    it { expect(result).to eq out: 'console.log("hello");   alert("WORLD");   console.log("!!");', exit: :passed }
  end


  context 'when test runner is implemented but no expectations' do
    before do
      class DemoTestHook < IntegrationTestBaseTestHook
      end
    end
    after do
      drop_hook DemoTestHook
    end

    it { expect(info[:expectations]).to be false }

    context 'when test passes' do
      before { allow_any_instance_of(DemoTestHook).to receive(:run!).and_return(['ok', :passed]) }

      it { expect(result).to eq out: 'ok', exit: :passed }
    end

    context 'when test returns structured results' do
      before { allow_any_instance_of(DemoTestHook).to receive(:run!).and_return([[['foo', :passed, ''], ['baz', :failed, 'bar']]]) }

      it { expect(result).to eq testResults: [
          {title: 'foo', status: :passed, result: ''},
          {title: 'baz', status: :failed, result: 'bar'}] }
    end

    context 'when test fails' do
      before { allow_any_instance_of(DemoTestHook).to receive(:run!).and_return(['nok', :failed]) }

      it { expect(result).to eq out: 'nok', exit: :failed }
    end

    context 'when test runner crashes' do
      before { allow_any_instance_of(DemoTestHook).to receive(:run!).and_raise('ups!') }
      it { expect(result[:exit]).to eq(:errored) }
      it { expect(result[:out]).to include('ups!') }
    end

    context 'when test runner compilation crashes' do
      before { allow_any_instance_of(DemoTestHook).to receive(:run!).and_raise(Mumukit::CompilationError, "this file has syntax errors") }
      it { expect(result).to eq out: 'this file has syntax errors', exit: :errored }
    end

    context 'when test is aborted' do
      before { allow_any_instance_of(DemoTestHook).to receive(:run!).and_return(['out of memory error', :aborted]) }

      it { expect(result).to eq out: 'out of memory error', exit: :aborted }
    end
    context 'when feedback runner is implemented' do
      before do
        class DemoFeedbackHook < Mumukit::Hook
        end
      end

      after do
        drop_hook DemoFeedbackHook
      end

      it { expect(info[:feedback]).to be true }

      context 'when feedback is given' do
        before { allow_any_instance_of(DemoTestHook).to receive(:run!).and_return(['ok', :passed]) }
        before { allow_any_instance_of(DemoFeedbackHook).to receive(:run!).and_return('Keep up the good work!') }
        it { expect(result[:feedback]).to eq('Keep up the good work!') }
      end
    end
  end

  context 'when expectations and test runner are implemented' do
    before do
      class DemoExpectationsHook < Mumukit::Hook
      end
      class DemoTestHook < IntegrationTestBaseTestHook
      end
    end

    after do
      drop_hook DemoTestHook
      drop_hook DemoExpectationsHook
    end

    it { expect(info[:expectations]).to be true }

    context 'when both passed' do
      let(:expectation_results) { [{expectation: {binding: :foo, inspection: :HasUsage}, result: true}] }
      before { allow_any_instance_of(DemoTestHook).to receive(:run!).and_return(['ok', :passed]) }
      before { allow_any_instance_of(DemoExpectationsHook).to receive(:compile) }
      before { allow_any_instance_of(DemoExpectationsHook).to receive(:run!).and_return(expectation_results) }

      it { expect(result).to eq out: 'ok', exit: :passed, expectationResults: expectation_results }
    end
    context 'when expectations crash' do
      before { allow_any_instance_of(DemoTestHook).to receive(:run!).and_return(['ok', :passed]) }
      before { allow_any_instance_of(DemoExpectationsHook).to receive(:compile) }
      before { allow_any_instance_of(DemoExpectationsHook).to receive(:run!).and_raise('ups!') }

      it { expect(result[:exit]).to eq(:errored) }
      it { expect(result[:out]).to include('ups!') }
    end
  end

  context 'when there are no tests but expectations' do
    before do
      class DemoExpectationsHook < Mumukit::Hook
      end
    end

    after do
      drop_hook DemoExpectationsHook
    end

    let(:expectation_results) { [{expectation: {binding: :foo, inspection: :HasUsage}, result: true}] }
    let(:result) { server.test!(req content: 'foo', expectations: [{binding: :foo, inspection: :HasUsage}]) }

    before { allow_any_instance_of(DemoExpectationsHook).to receive(:compile) }
    before { allow_any_instance_of(DemoExpectationsHook).to receive(:run!).and_return(expectation_results) }

    it { expect(result).to eq out: '', exit: :passed, expectationResults: expectation_results }
  end


  context 'when content is empty but extra is not' do
    after do
      drop_hook DemoExpectationsHook
      Mumukit.configure do |config|
        config.process_expectations_on_empty_content = false
      end
    end
    context 'and process empty content flag is true' do
      before do
        class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          include_smells true

          def language
            'Haskell'
          end

          def mulang_code(request)
            Mulang::Code.new(mulang_language, compile_content(request))
          end

          def compile_content(request)
            request[:content].presence || request[:extra]
          end

        end
        Mumukit.configure do |config|
          config.process_expectations_on_empty_content = true
        end
      end


      let(:expectation_results) { [{expectation: {binding: '*', inspection: 'DeclaresComputationWithArity1:foo'}, result: true}] }
      let(:result) { server.test!(req content: '', extra: 'foo x = x', expectations: [{binding: '*', inspection: 'DeclaresComputationWithArity1:foo'}]) }

      it { expect(result).to eq out: '', exit: :passed, expectationResults: expectation_results }
    end
    context 'and process empty content flag is false' do
      before do
        class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          include_smells true

          def language
            'Haskell'
          end

          def mulang_code(request)
            Mulang::Code.new(mulang_language, compile_content(request))
          end

          def compile_content(request)
            request[:content].presence || request[:extra]
          end
        end
      end

      let(:result) { server.test!(req extra: 'foo x = x', expectations: [{binding: '*', inspection: 'DeclaresComputationWithArity1:foo'}]) }

      it { expect(result).to eq out: '', exit: :passed }
    end
  end

  context 'when test is empty' do
    after do
      drop_hook DemoExpectationsHook
      Mumukit.configure do |config|
        config.run_test_hook_on_empty_test = false
      end
    end
    context 'and run test hook flag is true' do
      before do
        class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          include_smells true

          def language
            'Haskell'
          end

        end
        Mumukit.configure do |config|
          config.run_test_hook_on_empty_test = true
        end
      end


      let(:result) { server.test!(req content: '', extra: 'foo x = x') }

      it { expect(result).to eq out: 'unimplemented', exit: :aborted}
    end
    context 'and run test hook flag is true' do
      before do
        class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          include_smells true

          def language
            'Haskell'
          end
        end
      end

      let(:result) { server.test!(req extra: 'foo x = x') }

      it { expect(result).to eq out: '', exit: :passed }
    end
  end

  context 'when request is implemented' do
    before do
      class DemoValidationHook < Mumukit::Hook
      end
    end

    after do
      drop_hook DemoValidationHook
    end

    it { expect(info[:secure]).to be true }

    context 'when validation fails' do
      before do
        allow_any_instance_of(DemoValidationHook).to receive(:validate!).and_raise(Mumukit::RequestValidationError.new('never use File.new'))
      end
      it { expect(result[:exit]).to eq(:aborted) }
      it { expect(result[:out]).to eq('never use File.new') }
    end
  end
end
