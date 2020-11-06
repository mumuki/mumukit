require_relative 'spec_helper'

class SampleExplainer < Mumukit::Explainer
  def explain_foo(content, test_results)
    'foo'
  end
end

describe Mumukit::Explainer do
  context 'contains all explain methods' do
    it { expect(SampleExplainer.new.explain_methods).to eq [[:explain_foo, 'foo']] }
  end

  context 'explains in html' do
    before do
      Mumukit.configure do |config|
        config.content_type = 'html'
      end
    end

    it { expect(SampleExplainer.new.explain('code', 'errored')).to match(/<ul>\n<li>.*foo.*<\/li>\n<\/ul>/) }
  end

  context 'explains in markdown' do
    before do
      Mumukit.configure do |config|
        config.content_type = 'markdown'
      end
    end

    it { expect(SampleExplainer.new.explain('code', 'errored')).to match(/\* .*foo.*/) }
  end
end
