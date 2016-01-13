require_relative './spec_helper'

describe Mumukit::Server::TestServer do
  before do
    class QueryHook < Mumukit::Templates::FileHook
      include Mumukit::Templates::WithEmbeddedEnvironment

      def command_line(filename)
        "ruby < #{filename}"
      end

      def compile_file_content(req)
        "#{req.extra}\n#{req.content}\nprint('=> ' + (#{req.query}).inspect)"
      end
    end
  end

  after do
    drop_hook QueryHook
  end

  let(:server) { Mumukit::Server::TestServer.new(nil) }

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
