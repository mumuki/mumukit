require_relative './spec_helper'

describe Mumukit::Server::TestServer do
  before do
    class DemoQueryHook < Mumukit::Templates::FileHook
      with_error_patterns
      isolated false

      def command_line(filename)
        "ruby < #{filename}"
      end

      def compile_file_content(req)
        "#{req.extra}\n#{req.content}\nprint('=> ' + (#{req.query}).inspect)"
      end

      def error_patterns
        [
          Mumukit::ErrorPattern::Errored.new(/^syntax error: /),
          Mumukit::ErrorPattern::Errored.new(/^Warning: /, status: :passed)
        ]
      end
    end
  end

  after do
    drop_hook DemoQueryHook
  end

  let(:server) { Mumukit::Server::TestServer.new }

  it { expect(server.info('http://localhost')[:features][:query]).to be true }

  context 'just extra' do
    it { expect(server.query!(req query: '5')[:out]).to eq '=> 5' }
  end

  context 'no content' do
    it { expect(server.query!(req query: 'x', extra: 'x = 4')[:out]).to eq '=> 4' }
  end

  context 'with content' do
    it { expect(server.query!(req query: 'x', content: 'x = 4')[:out]).to eq '=> 4' }
  end

  context 'with content and effect' do
    it { expect(server.query!(req query: 'puts x', content: 'x = 4')[:out]).to eq "4\n=> nil" }
  end

  context 'with content and extra' do
    it { expect(server.query!(req query: 'x', content: 'x = y', extra: 'y = 3')[:out]).to eq '=> 3' }
  end

  context 'with error defined in patterns' do
    context 'failed status' do
      before { allow_any_instance_of(DemoQueryHook).to receive(:run_file!) { ['syntax error: unexpected end-of-input', :failed] } }

      it { expect(server.query!(req query: '[].map {')).to eq(exit: :errored, out: 'unexpected end-of-input') }
    end

    context 'passed status' do
      before { allow_any_instance_of(DemoQueryHook).to receive(:run_file!) { ['Warning: singleton variables found', :passed] } }

      it { expect(server.query!(req query: '[].map {')).to eq(exit: :errored, out: 'singleton variables found') }
    end
  end
end
