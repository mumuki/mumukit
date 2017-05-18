require_relative './spec_helper'

describe Mumukit::Server::TestServer do
  before do
    class DemoMetadataHook < Mumukit::Defaults::MetadataHook
      def spec_structure
        <<ruby
describe 'describe name' do
  it 'it name' do 
    expect(<Something>).to eq <Something>
  end
end
ruby
      end
    end
  end

  after do
    drop_hook DemoMetadataHook
  end

  let(:server) { Mumukit::Server::TestServer.new }

  it { expect(server.spec_structure).to eq "describe 'describe name' do\n  it 'it name' do \n    expect(<Something>).to eq <Something>\n  end\nend\n" }

end
