require_relative './spec_helper.rb'

describe Mumukit::WithCommandLine do
  include Mumukit::WithCommandLine

  def command_time_limit
    1
  end

  def limit_command
    'bin/limit'
  end

  it { expect(run_command %Q{ruby -e 'x = 1; while true; x = -x; end' 2>&1 }).to eq ['Time exceeded 1', :aborted] }
  it { expect(run_command %Q{ruby -e 'puts "bye"; exit 1' 2>&1 }).to eq ["bye\n", :failed] }
  it { expect(run_command %Q{ruby -e 'puts "hello"' 2>&1 }).to eq ["hello\n", :passed] }

end
