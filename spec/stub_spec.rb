require_relative './spec_helper.rb'

describe Mumukit::Hook do

  class DemoTestStub < Mumukit::Hook
  end

  let(:an_stub) { DemoTestStub.new(foo: 'bar') }

  it { expect(an_stub.foo).to eq 'bar' }
  it { expect { an_stub.baz }.to raise_error(NoMethodError) }
  it { expect { an_stub.foo(2) }.to raise_error(NoMethodError) }
  it { expect { an_stub.foo {} }.to raise_error(NoMethodError) }

end
