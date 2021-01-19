require_relative './spec_helper'

describe Mumukit::Runtime do
  let(:runtime) { Mumukit::Runtime.new({}) }

  it { expect(runtime.info[:mumukit_version]).to eq(Mumukit::VERSION) }
  it { expect(runtime.info[:features][:secure]).to be false }
  it { expect(runtime.info[:features][:sandboxed]).to be false }
  it { expect(runtime.info[:features][:feedback]).to be false }
  it { expect(runtime.info[:worker_image]).to eq 'alpine' }
  it { expect(runtime.info[:features][:query]).to be false }
  it { expect(runtime.info[:features][:precompile]).to be false }
  it { expect(runtime.info[:features][:multifile]).to be false }
  it { expect(runtime.info[:features][:settings]).to be false }

  it { expect(runtime.metadata_hook?).to be false }
  it { expect(runtime.metadata_hook).to be_a Mumukit::Defaults::MetadataHook }
  it { expect { runtime.foo_hook? }.to raise_error("Wrong hook foo") }
end
