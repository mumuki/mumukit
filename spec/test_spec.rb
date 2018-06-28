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

describe Mumukit::Runner do
  let(:hooks) { { test: test_hook } }
  let(:config) { {} }
  let(:runner) { Mumukit::Runner.create(config: config, hooks: hooks) }
  let(:result) { runner.run_test!(request) }
  let(:request) { req content: 'foo', test: 'bar', expectations: [] }
  let(:info) { runner.info[:features] }

  context 'when there are not tests and no expectations' do
    let(:hooks) { {} }
    it { expect(runner.run_test!(req content: 'foo')).to eq out: '<skipped>', exit: :passed }
  end

  describe 'filename hiding' do
    let(:config) { { docker_image: 'alpine' } }
    let(:test_hook) { Class.new(EchoPathTestRunner) }
    it { expect(result).to eq out: "path is solution_test.txt\n", exit: :passed }
  end

  describe 'with precompile hook' do
    let(:hooks) { { test: test_hook, precompile: precompile_hook } }
    let(:test_hook) do
      Class.new(Mumukit::Defaults::TestHook) do
        def run!(request)
          [request.something, :passed]
        end
      end
    end

    let(:precompile_hook) do
      Class.new(Mumukit::Hook) do
        def compile(request)
          struct request.to_h.merge(something: 'something precompiled')
        end
      end
    end

    it { expect(result).to eq out: "something precompiled", exit: :passed }
  end

  describe 'line number offset' do
    let(:config) { {docker_image: 'alpine'} }
    let(:test_hook) { Class.new(LineNumberTestRunner) }

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

  context 'when test runner is implemented but no expectations' do
    let(:test_hook) { Class.new(IntegrationTestBaseTestHook) }

    it { expect(info[:expectations]).to be false }

    context 'when test passes' do
      before { allow_any_instance_of(test_hook).to receive(:run!).and_return(['ok', :passed]) }

      it { expect(result).to eq out: 'ok', exit: :passed }
    end

    context 'when test returns structured results' do
      before { allow_any_instance_of(test_hook).to receive(:run!).and_return([[['foo', :passed, ''], ['baz', :failed, 'bar']]]) }

      it { expect(result).to eq testResults: [
          {title: 'foo', status: :passed, result: ''},
          {title: 'baz', status: :failed, result: 'bar'}] }
    end

    context 'when test fails' do
      before { allow_any_instance_of(test_hook).to receive(:run!).and_return(['nok', :failed]) }

      it { expect(result).to eq out: 'nok', exit: :failed }
    end

    context 'when test runner crashes' do
      before { allow_any_instance_of(test_hook).to receive(:run!).and_raise('ups!') }
      it { expect(result[:exit]).to eq(:errored) }
      it { expect(result[:out]).to include('ups!') }
    end

    context 'when test runner compilation crashes' do
      before { allow_any_instance_of(test_hook).to receive(:run!).and_raise(Mumukit::CompilationError, "this file has syntax errors") }
      it { expect(result).to eq out: 'this file has syntax errors', exit: :errored }
    end

    context 'when test is aborted' do
      before { allow_any_instance_of(test_hook).to receive(:run!).and_return(['out of memory error', :aborted]) }

      it { expect(result).to eq out: 'out of memory error', exit: :aborted }
    end
    context 'when feedback runner is implemented' do
      let(:hooks) { { test: test_hook, feedback: feedback_hook } }
      let(:feedback_hook) { Class.new(Mumukit::Hook) }

      it { expect(info[:feedback]).to be true }

      context 'when feedback is given' do
        before { allow_any_instance_of(test_hook).to receive(:run!).and_return(['ok', :passed]) }
        before { allow_any_instance_of(feedback_hook).to receive(:run!).and_return('Keep up the good work!') }
        it { expect(result[:feedback]).to eq('Keep up the good work!') }
      end
    end
  end

  context 'when expectations and test runner are implemented' do
    let(:hooks) { { test: test_hook, expectations: expectations_hook } }
    let(:test_hook) { Class.new(IntegrationTestBaseTestHook) }
    let(:expectations_hook) { Class.new(Mumukit::Hook) }

    it { expect(info[:expectations]).to be true }

    context 'when both passed' do
      let(:expectation_results) { [{expectation: {binding: :foo, inspection: :HasUsage}, result: true}] }
      before { allow_any_instance_of(test_hook).to receive(:run!).and_return(['ok', :passed]) }
      before { allow_any_instance_of(expectations_hook).to receive(:compile) }
      before { allow_any_instance_of(expectations_hook).to receive(:run!).and_return(expectation_results) }

      it { expect(result).to eq out: 'ok', exit: :passed, expectationResults: expectation_results }
    end
    context 'when expectations crash' do
      before { allow_any_instance_of(test_hook).to receive(:run!).and_return(['ok', :passed]) }
      before { allow_any_instance_of(expectations_hook).to receive(:compile) }
      before { allow_any_instance_of(expectations_hook).to receive(:run!).and_raise('ups!') }

      it { expect(result[:exit]).to eq(:errored) }
      it { expect(result[:out]).to include('ups!') }
    end
  end

  context 'when there are no tests but expectations' do
    let(:hooks) { { expectations: expectations_hook } }
    let(:expectations_hook) { Class.new(Mumukit::Hook) }

    let(:expectation_results) { [{expectation: {binding: :foo, inspection: :HasUsage}, result: true}] }
    let(:result) { runner.run_test!(req content: 'foo', expectations: [{binding: :foo, inspection: :HasUsage}]) }

    before { allow_any_instance_of(expectations_hook).to receive(:compile) }
    before { allow_any_instance_of(expectations_hook).to receive(:run!).and_return(expectation_results) }

    it { expect(result).to eq out: '<skipped>', exit: :passed, expectationResults: expectation_results }
  end


  context 'when content is empty but extra is not' do
    context 'and process empty content flag is true' do
      let(:hooks) { { expectations: expectations_hook } }
      let(:config) { { process_expectations_on_empty_content: true } }

      let(:expectations_hook) do
        Class.new(Mumukit::Templates::MulangExpectationsHook) do
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

      let(:expectation_results) { [{expectation: {binding: '*', inspection: 'DeclaresComputationWithArity1:foo'}, result: true}] }
      let(:result) { runner.run_test!(req content: '', extra: 'foo x = x', expectations: [{binding: '*', inspection: 'DeclaresComputationWithArity1:foo'}]) }

      it { expect(result).to eq out: '<skipped>', exit: :passed, expectationResults: expectation_results }
    end
    context 'and process empty content flag is false' do
      let(:hooks) { { expectations: expectations_hook } }
      let(:expectations_hook) do
        Class.new(Mumukit::Templates::MulangExpectationsHook) do
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

      let(:result) { runner.run_test!(req extra: 'foo x = x', expectations: [{binding: '*', inspection: 'DeclaresComputationWithArity1:foo'}]) }

      it { expect(result).to eq out: '<skipped>', exit: :passed }
    end
  end

  context 'when test is empty' do
    context 'and run test hook flag is true' do
      let(:hooks) { { expectations: expectations_hook } }
      let(:config) {  { run_test_hook_on_empty_test: true } }

      let(:expectations_hook) do
        Class.new(Mumukit::Templates::MulangExpectationsHook) do
          include_smells true

          def language
            'Haskell'
          end

        end
      end
      let(:result) { runner.run_test!(req content: '', extra: 'foo x = x') }
      it { expect(result).to eq out: 'unimplemented', exit: :aborted}
    end
    context 'and run test hook flag is true' do
      let(:hooks) { { expectations: expectations_hook } }
      let(:expectations_hook) do
        Class.new(Mumukit::Templates::MulangExpectationsHook) do
          include_smells true

          def language
            'Haskell'
          end
        end
      end

      let(:result) { runner.run_test!(req extra: 'foo x = x') }

      it { expect(result).to eq out: '<skipped>', exit: :passed }
    end
  end

  context 'when request is implemented' do
    let(:hooks) { { validation: validation_hook } }
    let(:validation_hook) { Class.new(Mumukit::Hook) }

    it { expect(info[:secure]).to be true }

    context 'when validation fails' do
      before do
        allow_any_instance_of(validation_hook).to receive(:validate!).and_raise(Mumukit::RequestValidationError.new('never use File.new'))
      end
      it { expect(result[:exit]).to eq(:aborted) }
      it { expect(result[:out]).to eq('never use File.new') }
    end
  end
end
