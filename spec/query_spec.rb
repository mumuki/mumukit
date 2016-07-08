require_relative './spec_helper'

describe Mumukit::Server::TestServer do
  before do
    class DemoQueryHook < Mumukit::Templates::FileHook
      isolated false

      def command_line(filename)
        "ruby < #{filename}"
      end

      def compile_file_content(req)
        "#{req.extra}\n#{req.content}\nprint('=> ' + (#{req.query}).inspect)"
      end
    end
  end

  after do
    drop_hook DemoQueryHook
  end

  let(:server) { Mumukit::Server::TestServer.new(nil) }

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

end
