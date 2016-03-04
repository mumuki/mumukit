require_relative './spec_helper'

describe Mumukit::Templates::MulangExpectationsHook do
  let(:content) { 'x = 1' }
  let(:usesX) { { subject: ['x'], transitive: false, negated: false, verb: 'uses', object: { tag: 'Anyone', contents: [] } }.deep_stringify_keys }
  let(:expectations) { [usesX] }

  after do
    drop_hook ExpectationsHook
  end

  let(:hook) { ExpectationsHook.new('mulang_path' => 'mulang') }

  context '#run!' do
    let(:request) { { content: content, expectations: expectations } }

    context 'when language is not defined' do
      before do
        class ExpectationsHook < Mumukit::Templates::MulangExpectationsHook
        end
      end

      it { expect { hook.run! request }.to raise_error(Exception, 'You need to implement method language') }
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
        allow_any_instance_of(ExpectationsHook).to receive(:run_command).and_return('{"results":[{"result":false,"expectation":{"subject":["x"],"transitive":false,"negated":false,"object":{"tag":"Anyone","contents":[]},"verb":"uses"}}],"smells":[]}')
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
        allow_any_instance_of(ExpectationsHook).to receive(:run_command).and_return('{"results":[{"result":false,"expectation":{"subject":["x"],"transitive":false,"negated":false,"object":{"tag":"Anyone","contents":[]},"verb":"uses"}}],"smells":[{"subject":["identidad"],"transitive":false,"negated":true,"object":{"tag":"Anyone","contents":[]},"verb":"HasRedundantLambda"}]}')
      end

      let(:hasRedundantLambda) { {subject: ['identidad'], transitive: false, negated: true, object: {tag: 'Anyone', contents: [] }, verb: 'HasRedundantLambda'}.deep_stringify_keys }

      it { expect(hook.run! request).to eq([{ 'expectation' => usesX, 'result' => false }, { 'expectation' => hasRedundantLambda, 'result' => false }]) }
    end
  end

  context '#mulang_json' do
    context 'with defaults' do
      before do
        class ExpectationsHook < Mumukit::Templates::MulangExpectationsHook
          def language
            'Haskell'
          end
        end
      end

      it { expect(hook.mulang_json content, expectations).to include(code: { content: 'x = 1', language: 'Haskell' }) }
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

      it { expect(hook.mulang_json content, expectations).to include(code: { content: '// x = 1 //', language: 'Haskell' }) }
    end
  end
end