require_relative './spec_helper'

describe Mumukit::Server::TestServer do
  before do
    class DemoTryHook < Mumukit::Templates::FileHook
      def compile_file_content(_r)
        ''
      end
    end

    allow_any_instance_of(DemoTryHook).to receive(:run!).and_return(['ok', :passed, {result: 'query_ok', status: :passed}])
  end
  after do
    drop_hook DemoTryHook
  end

  let(:server) { Mumukit::Server::TestServer.new }

  context 'valid try' do
    it { expect(server.try!(req query: 'echo something')).to eq out: 'ok', exit: :passed, queryResult: {result: 'query_ok', status: :passed} }
  end

end
