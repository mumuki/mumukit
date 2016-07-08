require_relative './spec_helper'

describe Mumukit::Templates::MulangExpectationsHook do
  let(:content) { 'x = 1' }
  let(:usesX) do
    {subject: ['x'],
     transitive: false,
     negated: false,
     verb: 'uses',
     object: {tag: 'Anyone', contents: []}}
  end
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
    let(:declaresWithArity1) do
      {subject: ['f'],
       transitive: false,
       negated: false,
       object: {tag: 'Anyone', contents: []},
       verb: 'declaresWithArity1'}
    end
    let(:redundantParameterSmell) do
      {subject: ['f'],
       transitive: false,
       negated: true,
       object: {tag: 'Anyone', contents: []},
       verb: 'HasRedundantParameter'}
    end
    let(:request) { {content: content, expectations: [declaresWithArity1]} }

    let(:result) { compile_and_run request }

    it { expect(result.length).to eq 2 }
    it { expect(result).to include(expectation: declaresWithArity1, result: true) }
    it { expect(result).to include(expectation: redundantParameterSmell, result: false) }
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

      it { expect(hook.compile content: content, expectations: expectations).to include(code: {content: 'x = 1', language: 'Haskell'}) }
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

      it { expect(hook.compile content: content, expectations: expectations).to include(code: {content: '// x = 1 //', language: 'Haskell'}) }
    end
  end
end