require_relative './spec_helper'

describe Mumukit::Runtime do
  let(:runtime) { Mumukit::Runtime.new(config: {docker_image: 'alpine'}) }

  it { expect(runtime.info[:mumukit_version]).to eq(Mumukit::VERSION) }
  it { expect(runtime.info[:features][:secure]).to be false }
  it { expect(runtime.info[:features][:sandboxed]).to be false }
  it { expect(runtime.info[:features][:feedback]).to be false }
  it { expect(runtime.info[:worker_image]).to eq 'alpine' }
  it { expect(runtime.info[:features][:query]).to be false }
  it { expect(runtime.info[:features][:precompile]).to be false }
  it { expect(runtime.hook_defined?(:metadata)).to be false }
  it { expect(runtime.new_hook(:metadata)).to be_a Mumukit::Defaults::MetadataHook }
  it { expect { runtime.new_hook(:foo) }.to raise_error }
end
