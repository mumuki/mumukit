require_relative 'spec_helper'

describe 'I18n concern' do

  it { expect(I18n.locale_available? :en).to be true }
  it { expect(I18n.locale_available? :es).to be true }
  it { expect(I18n.locale_available? :pt).to be true }

end
