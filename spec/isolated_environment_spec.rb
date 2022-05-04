require_relative './spec_helper'
require 'tempfile'

describe Mumukit::IsolatedEnvironment do
  class DemoRunner
    include Mumukit::Templates::WithIsolatedEnvironment,
            Mumukit::WithTempfile

    def tempfile_extension
      '.sh'
    end

    def command_line(file)
      "sh #{file}"
    end
  end

  context '#run_dir!' do
    let(:runner) { DemoRunner.new }
    let(:dir) { runner.write_tempdir!('solution' => 'echo foo') }
    let!(:volumes_at_start) { Docker::Volume.all.count }
    let!(:out) { runner.run_dir!(dir) }
    let(:volumes_at_end)    { Docker::Volume.all.count }

    it { expect(out).to eq ["foo\n", :passed] }

    it 'leaves no dangling volumes' do
      expect(volumes_at_end).to eq volumes_at_start
    end
  end
end
