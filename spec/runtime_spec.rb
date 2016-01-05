require_relative './spec_helper'

describe Mumukit::Runtime do
  let(:runtime) { Mumukit::Runtime.new({}) }

  it { expect(runtime.info[:mumukit_version]).to eq(Mumukit::VERSION) }
  it { expect(runtime.info[:features][:secure]).to be false }
  it { expect(runtime.info[:features][:sandboxed]).to be false }
  it { expect(runtime.info[:features][:feedback]).to be false }
  it { expect(runtime.info[:features][:query]).to be false }

end