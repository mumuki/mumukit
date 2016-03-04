require_relative './spec_helper'

describe Mumukit::Templates::MulangExpectationsHook do
  let(:content) { 'x = 1' }
  let(:expectations) { [{ subject: ['x'], transitive: false, negated: false, verb: 'uses', object: { tag: 'Anyone', contents: [] } }] }

  context '#run!' do
    let(:request) { { content: content, expectations: expectations } }

    context 'when language is not defined' do
      class WithoutLanguage < Mumukit::Templates::MulangExpectationsHook
      end

      let(:hook) { WithoutLanguage.new('mulang_path' => 'mulang') }
      it { expect { hook.run! request }.to raise_error(Exception, 'You need to implement method language') }
    end
  end

  context '#mulang_json' do
    after do
      drop_hook ExpectationsHook
    end

    let(:hook) { ExpectationsHook.new('mulang_path' => 'mulang') }

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