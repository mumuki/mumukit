require_relative './spec_helper'

describe Mumukit::Templates::MulangExpectationsHook do
  def compile_and_run(request)
    hook.run! hook.compile(request)
  end

  let(:hook) { DemoExpectationsHook.new }

  before do
    class DemoExpectationsHook < Mumukit::Templates::ExpectationsHook
    end
  end

  after do
    drop_hook DemoExpectationsHook
  end

  let(:content) { 'procedure Foo() { Put(Red) Put(Blue) }' }
  let(:containsFoo) { {binding: '*', inspection: 'SourceContains:Foo'} }
  let(:repeatsFoo) { {binding: '*', inspection: 'SourceRepeats:Foo'} }
  let(:notRepeatsPut) { {binding: '*', inspection: 'Not:SourceRepeats:Put'} }
  let(:notContainsFoo) { {binding: '*', inspection: 'Not:SourceContains:Foo'} }
  let(:notEquals) { {binding: '*', inspection: 'Not:SourceEquals:procedure Foo() { Put(Red) Put(Blue) }'} }
  let(:equalsIgnoreSpaces) { {binding: '*', inspection: 'SourceEqualsIgnoreSpaces:procedure Foo(){Put(Red)Put(Blue)}'} }
  let(:expectations) { [
    containsFoo,
    notContainsFoo,
    repeatsFoo,
    notRepeatsPut,
    notEquals,
    equalsIgnoreSpaces
  ] }

  let(:request) { struct content: content, expectations: expectations }

  let(:result) { compile_and_run request }

  it { expect(result.length).to eq expectations.length }

  it { expect(result).to include(expectation: containsFoo, result: true) }
  it { expect(result).to include(expectation: notContainsFoo, result: false) }
  it { expect(result).to include(expectation: repeatsFoo, result: false) }
  it { expect(result).to include(expectation: notRepeatsPut, result: false) }
  it { expect(result).to include(expectation: notEquals, result: false) }
  it { expect(result).to include(expectation: equalsIgnoreSpaces, result: true) }
end
