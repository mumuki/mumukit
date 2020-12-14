require_relative './spec_helper'

class TextChecker < Mumukit::Metatest::Checker
  def check_include(value, arg)
    fail "expected '#{value}' to include '#{arg}'" unless value.include? arg
  end

  def check_equal(value, arg)
    fail "expected '#{value}' to equal '#{arg}'" unless value == arg
  end

  def render_error_output(input, error_message)
    error_message
  end
end

class CustomErrorOutputChecker < TextChecker
  def render_error_output(input, error_message)
    "'#{input}' is not ok"
  end
end

describe 'metatest' do
  let(:result) { framework.test compilation, examples }
  let(:checker) { TextChecker.new }
  let(:framework) do
    Mumukit::Metatest::Framework.new checker: checker,
                                     runner: Mumukit::Metatest::IdentityRunner.new
  end

  describe 'full mode' do
    let(:examples) {
      [{
           name: 'has passion',
           postconditions: {include: 'passion'}
       }]
    }

    context 'pass' do
      let(:compilation) { 'escualo is passion' }
      it { expect(result).to eq [[['has passion', :passed, nil]]] }
    end
    context 'fails' do
      let(:compilation) { 'escualo is poison' }
      it { expect(result).to eq [[['has passion', :failed, "expected 'escualo is poison' to include 'passion'"]]] }
    end
  end

  describe 'implicit postconditions' do
    let(:examples) {
      [{
           name: 'kibi walked',
           include: 'walked'
       }]
    }

    context 'pass' do
      let(:compilation) { 'then kibi walked' }
      it { expect(result).to eq [[['kibi walked', :passed, nil]]] }
    end
    context 'fails' do
      let(:compilation) { 'then kibi run' }
      it { expect(result).to eq [[['kibi walked', :failed, "expected 'then kibi run' to include 'walked'"]]] }
    end
  end

  describe 'checker with custom input' do
    let(:checker) { CustomErrorOutputChecker.new }
    let(:examples) {
      [{
         name: 'kibi walked',
         include: 'walked'
       }]
    }

    context 'pass' do
      let(:compilation) { 'then kibi walked' }
      it { expect(result).to eq [[['kibi walked', :passed, nil]]] }
    end
    context 'fails' do
      let(:compilation) { 'then kibi run' }
      it { expect(result).to eq [[['kibi walked', :failed, "'then kibi run' is not ok"]]] }
    end
  end
end

