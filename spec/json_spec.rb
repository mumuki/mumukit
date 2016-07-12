require_relative 'spec_helper'

describe 'JSON' do
  it { expect { JSON.pretty_parse('fooo') }.to raise_error(/.*Invalid JSON fooo.*/) }
  it { expect(JSON.pretty_parse('{}')).to eq({}) }
end
