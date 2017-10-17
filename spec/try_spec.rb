require_relative './spec_helper'
require 'ostruct'

describe Mumukit::Server::TestServer do
  before do
    class DemoTryHook < Mumukit::Templates::TryHook
      def compile_file_content(_r)
        ''
      end
    end
  end
  after do
    drop_hook DemoTryHook
  end

  let(:server) { Mumukit::Server::TestServer.new }

  context 'valid try' do
    before { allow_any_instance_of(DemoTryHook).to receive(:run!).and_return(['ok', :passed, {result: 'query_ok', status: :passed}]) }
    it { expect(server.try!(req query: 'echo something', goal: {kind: :last_query_passes})).to eq out: 'ok', exit: :passed, queryResult: {result: 'query_ok', status: :passed} }
  end
end

describe Mumukit::Metatest::InteractiveChecker do
  before do
    class DemoTryHook < Mumukit::Templates::TryHook
      isolated true

      def command_line(f)
        ''
      end

      def compile_file_content(r)
        ''
      end

      def post_process_file(_file, result, status)
        check results
      end

      def results
      end
    end
  end
  after do
    drop_hook DemoTryHook
  end

  let(:hook) { DemoTryHook.new }
  let(:file) { hook.compile(request) }
  let(:result) { hook.run!(file) }

  context 'try with last_query_equals goal' do
    let(:goal) { { kind: 'last_query_equals', query: 'echo something' } }

    context 'and query that matches' do
      let(:request) { struct query: 'echo something', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'echo something else', goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_matches goal' do
    let(:goal) { { kind: 'last_query_matches', regex: /echo .*/ } }

    context 'and query that matches' do
      let(:request) { struct query: 'echo something', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'cat somewhere', goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_outputs goal' do
    let(:goal) { { kind: 'last_query_outputs', output: 'something' } }

    context 'and query with said output' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return query: {result: 'something'} }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query with a different output' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return query: {result: 'something else'} }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query with no output' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return query: {result: ''} }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with query_fails goal' do
    let(:goal) { { kind: 'query_fails', query: 'cd somewhere' } }

    context 'and query that makes said query pass' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return status: :passed }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query that makes said query fail' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return status: :failed }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end
  end

  context 'try with query_passes goal' do
    let(:goal) { { kind: 'query_passes', query: 'cd somewhere' } }

    context 'and query that makes said query pass' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return status: :passed }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'nd query that does not make said query fail' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return status: :failed }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with query_outputs goal' do
    let(:goal) { { kind: 'query_outputs', query: 'ls', output: 'somewhere' } }

    context 'and query that generates said output' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return goal: 'somewhere' }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not generate said output' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return goal: '' }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_passes goal' do
    let(:goal) { { kind: 'last_query_passes' } }

    context 'and query that passes' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return query: {status: :passed} }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that fails' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return query: {status: :failed} }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_fails goal' do
    let(:goal) { { kind: 'last_query_fails' } }

    context 'and query that fails' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return query: {status: :failed} }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that passes' do
      before { allow_any_instance_of(DemoTryHook).to receive(:results).and_return query: {status: :passed} }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

end
