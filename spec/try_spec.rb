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

  it { expect(server.info('http://localhost')[:features][:try]).to be true }

  context 'valid try' do
    before { allow_any_instance_of(DemoTryHook).to receive(:run!).and_return(['ok', :passed, {result: 'query_ok', status: :passed}]) }
    it { expect(server.try!(req query: 'echo something', goal: {kind: :last_query_passes})).to eq out: 'ok', exit: :passed, queryResult: {result: 'query_ok', status: :passed} }
  end
end

describe Mumukit::Metatest::InteractiveChecker do
  before do
    class DemoTryHook < Mumukit::Templates::TryHook
      attr_accessor :checker_options

      def command_line(f)
        'dont care'
      end

      def compile_file_content(r)
        'dont care'
      end

      def run_file!(*)
        ['', :passed]
      end

      def checker_options
        @checker_options || super
      end
    end
  end
  after do
    drop_hook DemoTryHook
  end

  let(:hook) { DemoTryHook.new }
  let(:file) { hook.compile(request) }
  let(:result) { hook.run!(file) }
  let(:structured_results) { { } }

  before { allow_any_instance_of(DemoTryHook).to receive(:to_structured_results).and_return structured_results }

  context 'when using string keys' do
    let(:goal) { {kind: 'last_query_equals', value: 'echo something' } }
    let(:request) { struct query: 'echo something', goal: goal }
    it { expect(result[1]).to eq :passed }
  end

  context 'try with last_query_equals goal' do
    let(:goal) { { kind: 'last_query_equals', value: 'echo something' } }

    context 'and query that matches' do
      let(:request) { struct query: 'echo something', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query with superfluous spaces that matches' do
      let(:request) { struct query: '  echo something  ', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'echo something else', goal: goal }
      it { expect(result[0]).to eq "query should be 'echo something' but was 'echo something else'" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_matches goal' do
    let(:goal) { { kind: 'last_query_matches', regexp: /echo .*/ } }

    context 'and query that matches' do
      let(:request) { struct query: 'echo something', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'cat somewhere', goal: goal }
      it { expect(result[0]).to eq "query should match regexp /echo .*/, but was 'cat somewhere'" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_matches goal, with regexp as string' do
    let(:goal) { { kind: 'last_query_matches', regexp: '^echo .*' } }

    context 'and query that matches' do
      let(:request) { struct query: 'echo something', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'cat somewhere', goal: goal }
      it { expect(result[0]).to eq "query should match regexp \"^echo .*\", but was 'cat somewhere'" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_matches goal, with stripping' do
    let(:goal) { { kind: 'last_query_matches', regexp: '^echo hello$' } }

    context 'and query that matches' do
      let(:request) { struct query: '   echo hello   ', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: '   echo world   ', goal: goal }
      it { expect(result[0]).to eq "query should match regexp \"^echo hello$\", but was 'echo world'" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_matches goal, with right stripping' do
    before { hook.checker_options = { strip_mode: :right_only } }
    let(:goal) { { kind: 'last_query_matches', regexp: '^echo hello$' } }

    context 'and query that matches' do
      let(:request) { struct query: 'echo hello   ', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: '   echo hello   ', goal: goal }
      it { expect(result[0]).to eq "query should match regexp \"^echo hello$\", but was '   echo hello'" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with queries_match' do
    let(:goal) { { kind: 'queries_match', regexps: ['echo hello', 'echo\W+world'] } }

    context 'and no query matches' do
      let(:request) { struct query: 'echo foo', goal: goal }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and only one query matches' do
      let(:request) { struct query: 'echo hello', goal: goal }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and only one query matches, with cookies' do
      let(:request) { struct query: 'echo hello', goal: goal, cookie: ['date'] }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'cat somewhere', goal: goal }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query that does not match, with cookies' do
      let(:request) { struct query: 'cat somewhere', goal: goal, cookie: ['date'] }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query and cookie matches' do
      let(:request) { struct query: 'echo  world', goal: goal, cookie: ['echo hello'] }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query and cookie matches, unordered' do
      let(:request) { struct query: 'echo hello', goal: goal, cookie: ['echo  world'] }
      it { expect(result[1]).to eq :passed }
    end

    context 'and cookie matches' do
      let(:request) { struct query: 'cat hello', goal: goal, cookie: ['echo hello', 'echo  world'] }
      it { expect(result[1]).to eq :passed }
    end

    context 'and cookie matches, unordered' do
      let(:request) { struct query: 'cat hello', goal: goal, cookie: ['echo hello', 'echo  world'] }
      it { expect(result[1]).to eq :passed }
    end
  end

  context 'try with queries_equal' do
    before { hook.checker_options = { strip_mode: :left_right_and_internal } }
    let(:goal) { { kind: 'queries_equal', values: ['echo hello', 'echo world'] } }

    context 'and no query matches' do
      let(:request) { struct query: 'echo foo', goal: goal }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and only one query matches' do
      let(:request) { struct query: 'echo hello', goal: goal }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and only one query matches, with cookies' do
      let(:request) { struct query: 'echo hello', goal: goal, cookie: ['date'] }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query that does not match' do
      let(:request) { struct query: 'cat somewhere', goal: goal }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query that does not match, with cookies' do
      let(:request) { struct query: 'cat somewhere', goal: goal, cookie: ['date'] }
      it { expect(result[0]).to eq 'All the required queries must be executed' }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query and cookie matches' do
      let(:request) { struct query: 'echo  world', goal: goal, cookie: ['echo hello'] }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query and cookie matches, unordered' do
      let(:request) { struct query: 'echo hello', goal: goal, cookie: ['echo  world'] }
      it { expect(result[1]).to eq :passed }
    end

    context 'and cookie matches' do
      let(:request) { struct query: 'cat hello', goal: goal, cookie: ['echo hello', 'echo  world'] }
      it { expect(result[1]).to eq :passed }
    end

    context 'and cookie matches, unordered' do
      let(:request) { struct query: 'cat hello', goal: goal, cookie: ['echo hello', 'echo  world'] }
      it { expect(result[1]).to eq :passed }
    end
  end


  context 'try with last_query_outputs goal' do
    let(:goal) { { kind: 'last_query_outputs', output: 'something' } }

    context 'and query with said output' do
      let(:structured_results) { { query: {result: 'something'} } }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query with a different output' do
      let(:structured_results) { { query: {result: 'something else'} } }
      let(:request) { struct goal: goal }
      it { expect(result[0]).to eq "query output should be 'something' but was 'something else'" }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query with no output' do
      let(:structured_results) { { query: {result: ''} } }
      let(:request) { struct goal: goal }
      it { expect(result[0]).to eq "query output should be 'something' but was ''" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_output_includes goal' do
    let(:goal) { { kind: 'last_query_output_includes', output: 'something' } }

    context 'and query with output that includes it' do
      let(:structured_results) { { query: {result: 'anything something everything'} } }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query with output that does not include it' do
      let(:structured_results) { { query: {result: 'nothing'} } }
      let(:request) { struct goal: goal }
      it { expect(result[0]).to eq "query output should include 'something' but was 'nothing'" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_output_like goal' do
    let(:goal) { { kind: 'last_query_output_like', output: 'Some thing' } }

    context 'and query with output that is like it' do
      let(:structured_results) { { query: {result: 'something'} } }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query with output that is not like it' do
      let(:structured_results) { { query: {result: 'nothing'} } }
      let(:request) { struct goal: goal }
      it { expect(result[0]).to eq "query output should be like 'Some thing' but was 'nothing'" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with query_fails goal' do
    let(:goal) { { kind: 'query_fails', query: 'cd somewhere' } }

    context 'and query that makes said query pass' do
      let(:structured_results) { { status: :passed } }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :failed }
    end

    context 'and query that makes said query fail' do
      let(:structured_results) { { status: :failed } }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end
  end

  context 'try with query_passes goal' do
    let(:goal) { { kind: 'query_passes', query: 'cd somewhere' } }

    context 'and query that makes said query pass' do
      let(:structured_results) { { status: :passed } }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'nd query that does not make said query fail' do
      let(:structured_results) { { status: :failed } }
      let(:request) { struct goal: goal }
      it { expect(result[0]).to eq "query 'cd somewhere' should pass but it failed" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with query_outputs goal' do
    let(:goal) { { kind: 'query_outputs', query: 'ls', output: 'somewhere' } }

    context 'and query that generates said output' do
      let(:structured_results) { { goal: 'somewhere' } }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that does not generate said output' do
      let(:structured_results) { { goal: '' } }
      let(:request) { struct goal: goal }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_passes goal' do
    let(:goal) { { kind: 'last_query_passes' } }

    context 'and query that passes' do
      let(:structured_results) { { query: {status: :passed} } }
      let(:request) { struct query: 'ls', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that fails' do
      let(:structured_results) { { query: {status: :failed} } }
      let(:request) { struct query: 'ls', goal: goal }
      it { expect(result[0]).to eq "query should pass but it was 'ls' and failed" }
      it { expect(result[1]).to eq :failed }
    end
  end

  context 'try with last_query_fails goal' do
    let(:goal) { { kind: 'last_query_fails' } }

    context 'and query that fails' do
      let(:structured_results) { { query: {status: :failed} } }
      let(:request) { struct query: 'ls', goal: goal }
      it { expect(result[1]).to eq :passed }
    end

    context 'and query that passes' do
      let(:structured_results) { { query: {status: :passed} } }
      let(:request) { struct query: 'ls', goal: goal }
      it { expect(result[0]).to eq "query should fail but it was 'ls' and passed" }
      it { expect(result[1]).to eq :failed }
    end
  end

end
