require_relative './spec_helper.rb'

include Mumukit

class SampleTestHook < FileTestHook
  def compile_file_content(r)
    "#{r.test}  #{r.extra}  #{r.content}"
  end
end

describe TestServer do
  let(:server) { TestServer.new }
  let(:result) { server.test!({'content' => 'foo', 'test' => 'bar', 'expectations' => []}) }
  let(:info) { server.info('http://localhost:8080')[:features] }

  context 'when there are not tests and no expectations' do
    it { expect(server.test!('content' => 'foo')).to eq({out: '', exit: :passed}) }
  end

  context 'when test runner is implemented but no expectations' do
    before do
      class TestHook < SampleTestHook
      end
    end
    after do
      drop_hook TestHook
    end

    it { expect(info[:expectations]).to be false }

    context 'when test passes' do
      before { allow_any_instance_of(TestHook).to receive(:run!).and_return(['ok', :passed]) }

      it { expect(result).to eq({out: 'ok', exit: :passed}) }
    end

    context 'when test returns structured results' do
      before { allow_any_instance_of(TestHook).to receive(:run!).and_return([[['foo', :passed, ''], ['baz', :failed, 'bar']]]) }

      it { expect(result).to eq({testResults: [
          {title: 'foo', status: :passed, result: ''},
          {title: 'baz', status: :failed, result: 'bar'}]}) }
    end

    context 'when test fails' do
      before { allow_any_instance_of(TestHook).to receive(:run!).and_return(['nok', :failed]) }

      it { expect(result).to eq({out: 'nok', exit: :failed}) }
    end

    context 'when test runner crashes' do
      before { allow_any_instance_of(TestHook).to receive(:run!).and_raise('ups!') }
      it { expect(result[:exit]).to eq(:errored) }
      it { expect(result[:out]).to include('ups!') }
    end

    context 'when test is aborted' do
      before { allow_any_instance_of(TestHook).to receive(:run!).and_return(['out of memory error', :aborted]) }

      it { expect(result).to eq({out: 'out of memory error', exit: :aborted}) }
    end
    context 'when feedback runner is implemented' do
      before do
        class FeedbackRunnerHook < Hook
        end
      end

      after do
        drop_hook FeedbackRunnerHook
      end

      it { expect(info[:feedback]).to be true }

      context 'when feedback is given' do
        before { allow_any_instance_of(TestHook).to receive(:run!).and_return(['ok', :passed]) }
        before { allow_any_instance_of(FeedbackRunnerHook).to receive(:run!).and_return('Keep up the good work!') }
        it { expect(result[:feedback]).to eq('Keep up the good work!') }
      end
    end
  end

  context 'when expectations and test runner are implemented' do
    before do
      class ExpectationsRunnerHook < Hook
      end
      class TestHook < SampleTestHook
      end
    end

    after do
      drop_hook TestHook
      drop_hook ExpectationsRunnerHook
    end

    it { expect(info[:expectations]).to be true }

    context 'when both passed' do
      let(:expectation_results) { [{expectation: {binding: :foo, inspection: :HasUsage}, result: true}] }
      before { allow_any_instance_of(TestHook).to receive(:run!).and_return(['ok', :passed]) }
      before { allow_any_instance_of(ExpectationsRunnerHook).to receive(:run!).and_return(expectation_results) }

      it { expect(result).to eq({out: 'ok', exit: :passed, expectationResults: expectation_results}) }
    end
    context 'when expectations crash' do
      before { allow_any_instance_of(TestHook).to receive(:run!).and_return(['ok', :passed]) }
      before { allow_any_instance_of(ExpectationsRunnerHook).to receive(:run!).and_raise('ups!') }

      it { expect(result[:exit]).to eq(:errored) }
      it { expect(result[:out]).to include('ups!') }
    end
  end

  context 'when there are no tests but expectations' do
    before do
      class ExpectationsRunnerHook < Hook
      end
    end

    after do
      drop_hook ExpectationsRunnerHook
    end

    let(:expectation_results) { [{expectation: {binding: :foo, inspection: :HasUsage}, result: true}] }
    let(:result) { server.test!('content' => 'foo', 'expectations' => [{binding: :foo, inspection: :HasUsage}]) }

    before { allow_any_instance_of(ExpectationsRunnerHook).to receive(:run!).and_return(expectation_results) }

    it { expect(result).to eq({out: '', exit: :passed, expectationResults: expectation_results}) }
  end


  context 'when request is implemented' do
    before do
      class RequestValidatorHook < Hook
      end
    end

    after do
      drop_hook RequestValidatorHook
    end

    it { expect(info[:secure]).to be true }

    context 'when validation fails' do
      before { allow_any_instance_of(RequestValidatorHook).to receive(:validate!).and_raise(RequestValidationError.new('never use File.new')) }
      it { expect(result[:exit]).to eq(:aborted) }
      it { expect(result[:out]).to eq('never use File.new') }
    end
  end
end
