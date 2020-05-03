require_relative './spec_helper'

describe Mulang::Expectation do
  it { expect(Mulang::Expectation.parse(binding: '*', inspection: 'SourceContains:f x').translate).to eq 'solution must use <strong>f x</strong>' }
end

describe Mumukit::Templates::MulangExpectationsHook do
  let(:content) { 'x = 1' }
  let(:usesX) { {binding: '*', inspection: 'Uses:X'} }
  let(:expectations) { [usesX] }

  after do
    drop_hook DemoExpectationsHook
  end

  def compile_and_run(request)
    hook.run! hook.compile(request)
  end

  let(:hook) { DemoExpectationsHook.new('mulang_path' => './bin/mulang') }

  context 'when code is well formed' do
    before do
      class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
        include_smells true

        def language
          'Haskell'
        end
      end
    end

    context 'when using expectations' do
      let(:content) { 'f x = f x' }

      let(:declaresComputationWithArity1) { {binding: '*', inspection: 'DeclaresComputationWithArity1:f'} }
      let(:usesIf) { {binding: 'f', inspection: 'UsesIf'} }
      let(:containsFx) { {binding: '*', inspection: 'SourceContains:f x'} }
      let(:hasBindingF) { {binding: 'f', inspection: 'HasBinding'} }
      let(:hasBindingG) { {binding: 'g', inspection: 'HasBinding'} }
      let(:redundantParameterSmell) { {binding: 'f', inspection: 'HasRedundantParameter'} }
      let(:exceptHasTooShortIdentifiers) { {binding: '*', inspection: 'Except:HasTooShortIdentifiers'} }
      let(:exceptNonExistingSmell) { {binding: '*', inspection: 'Except:NonExistingSmell'} }

      let(:request) { {
        content: content,
        expectations: [
          declaresComputationWithArity1,
          usesIf,
          containsFx,
          hasBindingF,
          hasBindingG,
          exceptHasTooShortIdentifiers,
          exceptNonExistingSmell ] } }

      let(:result) { compile_and_run request }

      it { expect(result.length).to eq 7 }

      it { expect(result).to include(expectation: declaresComputationWithArity1, result: true) }

      it { expect(result).to include(expectation: usesIf, result: false) }

      it { expect(result).to include(expectation: containsFx, result: true) }

      it { expect(result).to include(expectation: {binding: '*', inspection: 'Declares:=f'}, result: true) }
      it { expect(result).to include(expectation: {binding: '*', inspection: 'Declares:=g'}, result: false) }

      it { expect(result).to include(expectation: redundantParameterSmell, result: false) }
      it { expect(result).to_not include(expectation: {binding: 'f', inspection: 'HasTooShortIdentifiers'}, result: false) }
    end

    context 'when using custom expectations' do
      let(:content) { 'foo x = baz (y + 1)' }
      let(:custom_expectations) do
        %q{
          expectation "assigns variable": assigns;
          expectation "calls something": calls;
          expectation "calls something with math": calls with math;
        }
      end

      let(:request) { {content: content, custom_expectations: custom_expectations} }

      let(:result) { compile_and_run request }

      it { expect(result.length).to eq 3 }

      it do
        expect(result).to eq [
          {expectation: {inspection: "assigns variable", binding: "<<custom>>"}, result: false},
          {expectation: {inspection: "calls something", binding: "<<custom>>"}, result: true},
          {expectation: {inspection: "calls something with math", binding: "<<custom>>"}, result: true}
        ]
      end
    end
  end

  context 'when language is not defined' do
    let(:request) { {content: content, expectations: expectations} }

    before do
      class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
      end
    end

    it { expect { compile_and_run request }.to raise_error(Exception, 'You have to provide a Mulang-compatible language in order to use this hook') }
  end

  context 'when language is provided and there are syntax errors on content' do
    let(:request) { {content: 'sadsadas', expectations: expectations} }

    before do
      class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
        def language
          'Haskell'
        end
      end
    end

    it { expect { compile_and_run request }.to raise_error(Mumukit::CompilationError, 'Parse error') }
  end

  describe 'compile_mulang_analysis' do
    let(:sample) do
      hook.compile_mulang_analysis(
        {content: content, expectations: expectations},
        {ast: [], source: [], exceptions: []})
    end

    context 'with defaults' do
      before do
        class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          def language
            'Haskell'
          end
        end
      end

      it { expect(sample).to include sample: {
                              tag: 'CodeSample',
                              content: 'x = 1',
                              language: 'Haskell' } }
    end

    context 'when transform_content is provided' do
      before do
        class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          def language
            'Haskell'
          end

          def compile_content(content)
            "// #{content} //"
          end
        end
      end

      it { expect(sample).to include sample: {
                            tag: 'CodeSample',
                            content: '// x = 1 //',
                            language: 'Haskell'} }
    end
  end
end
