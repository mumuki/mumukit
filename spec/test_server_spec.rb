require 'rspec'

require_relative '../lib/mumukit'

class TestCompiler
  def compile(x, y, z)
    "#{x}  #{y}  #{z}"
  end
end

include Mumukit

describe TestServer do
  let(:server) { TestServer.new(nil) }
  let(:result) { server.run!({'content' => 'foo', 'test' => 'bar', 'expectations' => []}) }


  context 'when test passes' do
    before { allow_any_instance_of(TestRunner).to receive(:run_test_file!).and_return(['ok', :passed]) }

    it { expect(result).to eq({out: 'ok', exit: :passed, expectationResults: []}) }
  end

  context 'when test fails' do
    before { allow_any_instance_of(TestRunner).to receive(:run_test_file!).and_return(['nok', :failed]) }

    it { expect(result).to eq({out: 'nok', exit: :failed, expectationResults: []}) }
  end

  context 'when expectations is implemented and passes' do
    let(:expectation_results) { [{expectation: {binding: :foo, inspection: :HasUsage}, result: true}] }
    before { allow_any_instance_of(TestRunner).to receive(:run_test_file!).and_return(['ok', :passed]) }
    before { allow_any_instance_of(ExpectationsRunner).to receive(:run_expectations!).and_return(expectation_results) }

    it { expect(result).to eq({out: 'ok', exit: :passed, expectationResults: expectation_results}) }
  end

  context 'when expectations is implemented but crashes' do
    before { allow_any_instance_of(TestRunner).to receive(:run_test_file!).and_return(['ok', :passed]) }
    before { allow_any_instance_of(ExpectationsRunner).to receive(:run_expectations!).and_raise('ups!') }

    it { expect(result[:exit]).to eq(:failed) }
    it { expect(result[:out]).to include('ups!') }
  end

  context 'when test runner crashes' do
    before { allow_any_instance_of(TestRunner).to receive(:run_test_file!).and_raise('ups!') }
    it { expect(result[:exit]).to eq(:failed) }
    it { expect(result[:out]).to include('ups!') }
  end
end
