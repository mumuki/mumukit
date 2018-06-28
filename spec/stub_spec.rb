require_relative './spec_helper.rb'

describe Mumukit::Hook do

  class DemoTestStub < Mumukit::Hook
  end

  let(:an_stub) { DemoTestStub.new(struct foo: 'bar') }

  it { expect(an_stub.config.foo).to eq 'bar' }
  it { expect { an_stub.baz }.to raise_error(NoMethodError) }

end
