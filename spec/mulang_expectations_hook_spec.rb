require_relative './spec_helper'

describe Mumukit::Templates::MulangExpectationsHook do
  let(:content) { 'x = 1' }
  let(:usesX) { { subject: ['x'], transitive: false, negated: false, verb: 'uses', object: { tag: 'Anyone', contents: [] } }.deep_stringify_keys }
  let(:expectations) { [usesX] }

  after do
    drop_hook ExpectationsHook
  end

  let(:hook) { ExpectationsHook.new('mulang_path' => './bin/mulang') }

  context 'integration' do
    before do
      class ExpectationsHook < Mumukit::Templates::MulangExpectationsHook
        include_smells true

        def language
          'Haskell'
        end
      end
    end

    let(:content) { 'f x = f x' }
    let(:declaresWithArity1) { {subject:['f'],transitive:false,negated:false,object:{tag:'Anyone',contents:[]},verb:'declaresWithArity1'}.deep_stringify_keys }
    let(:redundantParameterSmell) { {subject:['f'],transitive:false,negated:true,object:{tag:'Anyone',contents:[]},verb:'HasRedundantParameter'}.deep_stringify_keys }
    let(:request) { { content: content, expectations: [declaresWithArity1] } }

    let(:result) { hook.run! request }

    it { expect(result.length).to eq 2 }
    it { expect(result).to include({ 'expectation' => declaresWithArity1, 'result' => true }) }
    it { expect(result).to include({ 'expectation' => redundantParameterSmell, 'result' => false }) }
  end

  context '#run!' do
    def mock_mulang_output(output)
      allow_any_instance_of(ExpectationsHook).to receive(:run_command).and_return([output, :passed])
    end

    let(:request) { { content: content, expectations: expectations } }

    context 'when language is not defined' do
      before do
        class ExpectationsHook < Mumukit::Templates::MulangExpectationsHook
        end
      end

      it { expect { hook.run! request }.to raise_error(Exception, 'You have to provide a Mulang-compatible language in order to use this hook') }
    end

    context 'transforms the results json into a hash' do
      before do
        class ExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          def language
            'Haskell'
          end
        end
      end

      before do
        mock_mulang_output '{"results":[{"result":false,"expectation":{"subject":["x"],"transitive":false,"negated":false,"object":{"tag":"Anyone","contents":[]},"verb":"uses"}}],"smells":[]}'
      end

      it { expect(hook.run! request).to eq([{ 'expectation' => usesX, 'result' => false }]) }
    end

    context 'when smells are enabled' do
      before do
        class ExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          include_smells true

          def language
            'Haskell'
          end
        end
      end

      before do
        mock_mulang_output '{"results":[{"result":false,"expectation":{"subject":["x"],"transitive":false,"negated":false,"object":{"tag":"Anyone","contents":[]},"verb":"uses"}}],"smells":[{"subject":["identidad"],"transitive":false,"negated":true,"object":{"tag":"Anyone","contents":[]},"verb":"HasRedundantLambda"}]}'
      end

      let(:hasRedundantLambda) { {subject: ['identidad'], transitive: false, negated: true, object: {tag: 'Anyone', contents: [] }, verb: 'HasRedundantLambda'}.deep_stringify_keys }

      it { expect(hook.run! request).to eq([{ 'expectation' => usesX, 'result' => false }, { 'expectation' => hasRedundantLambda, 'result' => false }]) }
    end
  end

  context '#mulang_input' do
    context 'with defaults' do
      before do
        class ExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          def language
            'Haskell'
          end
        end
      end

      it { expect(hook.mulang_input content, expectations).to include(code: { content: 'x = 1', language: 'Haskell' }) }
    end

    context 'when transform_content is provided' do
      before do
        class ExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          def language
            'Haskell'
          end

          def transform_content(content)
            "// #{content} //"
          end
        end
      end

      it { expect(hook.mulang_input content, expectations).to include(code: { content: '// x = 1 //', language: 'Haskell' }) }
    end
  end
end