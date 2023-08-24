require_relative 'spec_helper'

class SampleExplainer < Mumukit::Explainer
  def explain_returning_str(content, test_results)
    'a_str'
  end

  def explain_returing_true(content, test_results)
    true
  end

  def explain_returing_nil(content, test_results)
  end

  def explain_returning_hash(content, test_results)
    {x: 1, y: 2}
  end
end

describe Mumukit::Explainer do
  let(:explanation) { SampleExplainer.new.explain('code', 'errored') }

  context 'contains all explain methods' do
    it do
      expect(SampleExplainer.new.send(:explain_methods)).to match_array [
        [:explain_returning_str, 'returning_str'],
        [:explain_returing_true, 'returing_true'],
        [:explain_returing_nil, 'returing_nil'],
        [:explain_returning_hash, 'returning_hash'],
      ]
    end
  end

  context 'only considers truthy results' do
    it do
      expect(SampleExplainer.new.send(:eval_explain_methods, 'code', 'errored')).to match_array [
        {key: 'returning_str', binding: {}},
        {key: 'returing_true', binding: {}},
        {key: 'returning_hash', binding: {x: 1, y: 2}}
      ]
    end
  end

  context 'explains in html' do
    before do
      Mumukit.configure do |config|
        config.content_type = 'html'
      end
    end

    it { expect(explanation).to match(/<ul>.*<\/ul>/m) }

    it { expect(explanation).to match(/\n<li>.*returning_str.*<\/li>\n/) }
    it { expect(explanation).to match(/\n<li>.*returning_str.*<\/li>\n/) }
    it { expect(explanation).to match(/\n<li>.*returing_true.*<\/li>\n/) }
    it { expect(explanation).to match(/\n<li>.*returning_hash.*<\/li>\n/) }

    it { expect(explanation).to_not match(/\n<li>.*returing_nil.*<\/li>\n/) }
  end

  context 'explains in markdown' do
    before do
      Mumukit.configure do |config|
        config.content_type = 'markdown'
      end
    end

    it { expect(explanation).to match(/\* .*returning_str.*/) }
    it { expect(explanation).to match(/\* .*returing_true.*/) }
    it { expect(explanation).to match(/\* .*returning_hash.*/) }

    it { expect(explanation).to_not match(/\* .*returning_nil.*/) }
  end
end
