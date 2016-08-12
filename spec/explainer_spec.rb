require_relative 'spec_helper'

class SampleExplainer < Mumukit::Explainer
  def explain_foo(content, test_results)
  end
end

describe Mumukit::Explainer do
  it { expect(SampleExplainer.new.explain_methods).to eq [[:explain_foo, 'foo']] }
end