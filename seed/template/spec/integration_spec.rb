require 'mumukit/bridge'
require 'active_support/all'

describe 'runner' do
  let(:bridge) { Mumukit::Bridge::Runner.new('http://localhost:4569') }

  before(:all) do
    @pid = Process.spawn 'rackup -p 4569', err: '/dev/null'
    sleep 3
  end
  after(:all) { Process.kill 'TERM', @pid }

  it 'sample test' do
    response = bridge.run_tests!(test: '...',
                                 extra: '...',
                                 content: '...',
                                 expectations: [])

    expect(response).to eq(response_type: :structured,
                           test_results: [],
                           status: :passed,
                           feedback: '',
                           expectation_results: [],
                           result: '')
  end
end
