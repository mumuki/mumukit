require_relative 'spec_helper'

class SampleCookie < Mumukit::Cookie
  def statements_code
    statements.join("\n")
  end

  def stdout_separator_code
    "puts '#{stdout_separator}'"
  end
end

describe Mumukit::Cookie do
  let(:cookie) { SampleCookie.new(['foo', 'puts "foobaz"']) }
  it { expect(cookie.code).to include "foo\nputs \"foobaz\"\n" }
  it { expect(cookie.trim("foobaz\n#{cookie.stdout_separator}\ngoo\n")).to eq "goo\n" }
end