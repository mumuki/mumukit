require_relative './spec_helper.rb'

include Mumukit

class TestCompiler < FileTestCompiler
  def compile(r)
    "#{r.test}  #{r.extra}  #{r.content}"
  end
end

class TestRunner < Hook

end

describe TestServer do
  let(:server) { TestServer.new }
  let(:result) { server.test!({'content' => 'foo', 'test' => 'bar', 'expectations' => []}) }

  context 'when there are not tests and no expectations' do
    it { expect(server.test!('content'=> 'foo')).to eq({out: '', exit: :passed}) }
  end

  context 'when test passes' do
    before { allow_any_instance_of(TestRunner).to receive(:run_compilation!).and_return(['ok', :passed]) }

    it { expect(result).to eq({out: 'ok', exit: :passed}) }
  end

  context 'when test returns structured results' do
    before { allow_any_instance_of(TestRunner).to receive(:run_compilation!).and_return([[['foo', :passed, ''], ['baz', :failed, 'bar']]]) }

    it { expect(result).to eq({testResults: [
                                  {title: 'foo', status: :passed, result: ''},
                                  {title: 'baz', status: :failed, result: 'bar'}]}) }
  end

  context 'when test fails' do
    before { allow_any_instance_of(TestRunner).to receive(:run_compilation!).and_return(['nok', :failed]) }

    it { expect(result).to eq({out: 'nok', exit: :failed}) }
  end

  context 'when test is aborted' do
    before { allow_any_instance_of(TestRunner).to receive(:run_compilation!).and_return(['out of memory error', :aborted]) }

    it { expect(result).to eq({out: 'out of memory error', exit: :aborted}) }
  end

  context 'when expectations is implemented and passes' do
    let(:expectation_results) { [{expectation: {binding: :foo, inspection: :HasUsage}, result: true}] }
    before { allow_any_instance_of(TestRunner).to receive(:run_compilation!).and_return(['ok', :passed]) }
    before { allow_any_instance_of(ExpectationsRunner).to receive(:run_expectations!).and_return(expectation_results) }

    it { expect(result).to eq({out: 'ok', exit: :passed, expectationResults: expectation_results}) }
  end

  context 'when there are no tests but expectations' do
    let(:expectation_results) { [{expectation: {binding: :foo, inspection: :HasUsage}, result: true}] }
    let(:result) { server.test!('content' => 'foo', 'expectations' => [{binding: :foo, inspection: :HasUsage}]) }

    before { allow_any_instance_of(ExpectationsRunner).to receive(:run_expectations!).and_return(expectation_results) }

    it { expect(result).to eq({out: '', exit: :passed, expectationResults: expectation_results}) }
  end

  context 'when expectations is implemented but crashes' do
    before { allow_any_instance_of(TestRunner).to receive(:run_compilation!).and_return(['ok', :passed]) }
    before { allow_any_instance_of(ExpectationsRunner).to receive(:run_expectations!).and_raise('ups!') }

    it { expect(result[:exit]).to eq(:errored) }
    it { expect(result[:out]).to include('ups!') }
  end

  context 'when test runner crashes' do
    before { allow_any_instance_of(TestRunner).to receive(:run_compilation!).and_raise('ups!') }
    it { expect(result[:exit]).to eq(:errored) }
    it { expect(result[:out]).to include('ups!') }
  end

  context 'when feedback is given by the feedback runner' do
    before { allow_any_instance_of(TestRunner).to receive(:run_compilation!).and_return(['ok', :passed]) }
    before { allow_any_instance_of(FeedbackRunner).to receive(:run_feedback!).and_return('Keep up the good work!') }
    it { expect(result[:feedback]).to eq('Keep up the good work!') }
  end

  context 'when request validator fails' do
    before { allow_any_instance_of(RequestValidator).to receive(:validate!).and_raise(RequestValidationError.new('never use File.new')) }
    it { expect(result[:exit]).to eq(:aborted) }
    it { expect(result[:out]).to eq('never use File.new') }
  end
end
