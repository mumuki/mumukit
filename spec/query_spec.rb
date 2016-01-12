require_relative './spec_helper'

describe Mumukit::TestServer do
  before do
    class QueryHook < Mumukit::Hook
      include Mumukit::WithTempfile
      include Mumukit::WithCommandLine

      def run!(compilation)
        f = write_tempfile! compilation
        run_command "ruby < #{f.path}"
      ensure
        f.unlink
      end

      def compile(req)
        "#{req.extra}\n#{req.content}\nprint('=> ' + (#{req.query}).inspect)"
      end
    end
  end

  after do
    drop_hook QueryHook
  end

  let(:server) { Mumukit::TestServer.new(nil) }

  it { expect(server.info('http://localhost')[:features][:query]).to be true }

  context 'just extra' do
    it { expect(server.query!(query: '5')[:out]).to eq '=> 5' }
  end

  context 'no content' do
    it { expect(server.query!(query: 'x', extra: 'x = 4')[:out]).to eq '=> 4' }
  end

  context 'with content' do
    it { expect(server.query!(query: 'x', content: 'x = 4')[:out]).to eq '=> 4' }
  end

  context 'with content and effect' do
    it { expect(server.query!(query: 'puts x', content: 'x = 4')[:out]).to eq "4\n=> nil" }
  end

  context 'with content and extra' do
    it { expect(server.query!(query: 'x', content: 'x = y', extra: 'y = 3')[:out]).to eq '=> 3' }
  end

end
