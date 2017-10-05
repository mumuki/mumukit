require_relative './spec_helper.rb'

class IntegrationTestBaseTryHook < Mumukit::Templates::FileHook
  def compile_file_content(r)
    "#{r.test}  #{r.extra}  #{r.content}"
  end
end


class EchoPathTryRunner < Mumukit::Templates::FileHook
  isolated true

  def tempfile_extension
    '_test.txt'
  end

  def compile_file_content(*)
    ''
  end

  def command_line(path)
    "echo path is #{path}"
  end
end

describe Mumukit::Server::TestServer do
  let(:server) { Mumukit::Server::TestServer.new }
  let(:result) { server.test!(request) }
  let(:request) { req content: 'foo', test: 'bar', expectations: [] }
  let(:info) { server.info('http://localhost:8080')[:features] }

  before { Mumukit.configure_runtime(nil) }

  context 'when test runner is implemented but no expectations' do
    before do
      class DemoTryHook < IntegrationTestBaseTryHook
      end
    end
    after do
      drop_hook DemoTryHook
    end

    it { expect(info[:expectations]).to be false }

    context 'when test returns structured results' do
      before { allow_any_instance_of(DemoTryHook).to receive(:run!).and_return([[['foo', :passed, ''], ['baz', :failed, 'bar']]]) }

      it { expect(result).to eq testResults: [
          {title: 'foo', status: :passed, result: ''},
          {title: 'baz', status: :failed, result: 'bar'}] }
    end

  end

end
