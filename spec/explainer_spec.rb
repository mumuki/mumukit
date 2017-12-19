require_relative 'spec_helper'

class SampleExplainer < Mumukit::Explainer
  def explain_foo(content, test_results)
  end
end

class InlineErrorsExplainer < Mumukit::Explainer
  def explain_foo(content, test_results)
    [ {where: 'here'} ]
  end

  def explain_bar(content, test_results)
    [ {type: :error, line: '10'} ]
  end

  def explain_baz(content, test_results)
    [ {type: :warning, line: '3', column: '4'} ]
  end
end

describe Mumukit::Explainer do
  before do
    allow(I18n).to receive(:t) do |*args|
      key = args[0]
      bindings = args[1] || []
      "error #{key} #{bindings.map {|key, value| "#{key}: #{value}"}.join ' '}"
    end
  end
  it { expect(SampleExplainer.new.explain_methods).to eq [[:explain_foo, 'foo']] }

  describe 'explain' do
    let(:explain) { InlineErrorsExplainer.new.explain(content, test_results) }
    let(:content) { 'foo' }
    let(:test_results) { 'abc' }

    it { expect(explain).to eq [  {message: '* error foo where: here'},
                                  {type: :error, message: 'error bar ', line: 10},
                                  {type: :warning, message: 'error baz ', line: 3, column: 4}] }
  end


end