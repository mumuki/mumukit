require_relative './spec_helper'

describe Mumukit::Templates::MulangExpectationsHook do
  let(:content) { 'x = 1' }
  let(:usesX) { {binding: '', inspection: 'Uses:X'} }
  let(:expectations) { [usesX] }

  after do
    drop_hook DemoExpectationsHook
  end

  def compile_and_run(request)
    hook.run! hook.compile(request)
  end

  let(:hook) { DemoExpectationsHook.new('mulang_path' => './bin/mulang') }

  context 'integration' do
    before do
      class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
        include_smells true

        def language
          'Haskell'
        end
      end
    end

    let(:content) { 'f x = f x' }

    let(:declaresComputationWithArity1) { {binding: '', inspection: 'DeclaresComputationWithArity1:f'} }
    let(:usesIf) { {binding: 'f', inspection: 'UsesIf'} }
    let(:hasBindingF) { {binding: 'f', inspection: 'HasBinding'} }
    let(:hasBindingG) { {binding: 'g', inspection: 'HasBinding'} }
    let(:redundantParameterSmell) { {binding: 'f', inspection: 'HasRedundantParameter'} }
    let(:exceptHasTooShortBindings) { {binding: '', inspection: 'Except:HasTooShortBindings'} }

    let(:request) { {
      content: content,
      expectations: [declaresComputationWithArity1, usesIf, hasBindingF, hasBindingG, exceptHasTooShortBindings]} }

    let(:result) { compile_and_run request }

    it { expect(result.length).to eq 5 }

    it { expect(result).to include(expectation: declaresComputationWithArity1, result: true) }

    it { expect(result).to include(expectation: usesIf, result: false) }

    it { expect(result).to include(expectation: {binding: '', inspection: 'Declares:=f'}, result: true) }
    it { expect(result).to include(expectation: {binding: '', inspection: 'Declares:=g'}, result: false) }

    it { expect(result).to include(expectation: redundantParameterSmell, result: false) }
    it { expect(result).to_not include(expectation: {binding: 'f', inspection: 'HasTooShortBindings'}, result: false) }
  end
  context '#run!' do
    let(:request) { {content: content, expectations: expectations} }

    context 'when language is not defined' do
      before do
        class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
        end
      end

      it { expect { compile_and_run request }.to raise_error(Exception, 'You have to provide a Mulang-compatible language in order to use this hook') }
    end
  end
  context '#mulang_input' do
    context 'with defaults' do
      before do
        class DemoExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          def language
            'Haskell'
          end
        end
      end

      it { expect(hook.compile_json_file_content content: content, expectations: expectations)
                .to include sample: {
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

      it { expect(hook.compile_json_file_content content: content, expectations: expectations)
              .to include sample: {
                            tag: 'CodeSample',
                            content: '// x = 1 //',
                            language: 'Haskell'} }
    end
  end
end
