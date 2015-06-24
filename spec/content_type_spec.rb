require_relative '../spec/spec_helper'

describe Mumukit::ContentType do

  it { expect(Mumukit::ContentType.parse(:plain)).to eq Mumukit::ContentType::Plain }
  it { expect(Mumukit::ContentType.parse(:markdown)).to eq Mumukit::ContentType::Markdown }
  it { expect(Mumukit::ContentType.parse(:html)).to eq Mumukit::ContentType::Html }

end
