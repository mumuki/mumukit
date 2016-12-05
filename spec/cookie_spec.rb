require_relative 'spec_helper'

class SampleCookie < Mumukit::Cookie
  def statements_code
    statements.join("\n")
  end

  def stdout_separator_code
    "puts '#{stdout_separator}'"
  end
end

class SampleCookieHook < Mumukit::Hook
  stateful_through SampleCookie
end

describe Mumukit::Cookie do
  let(:cookie) { SampleCookie.new(['foo', 'puts "foobaz"']) }
  it { expect(cookie.code).to include "foo\nputs \"foobaz\"\n" }
  it { expect(cookie.trim("foobaz\n#{cookie.stdout_separator}\ngoo\n")).to eq "goo\n" }
end

describe Mumukit::Templates::WithCookie do
  let(:hook) { SampleCookieHook.new(nil) }

  it do
    expect(hook.build_cookie_code(struct cookie: %w(foo bar))).to eq "foo\nbar\nputs '!!!!MUMUKI-COOKIE-STDOUT-SEPARATOR-END!!!!'\n"
    expect(hook.trim_cookie_output("foo\b!!!!MUMUKI-COOKIE-STDOUT-SEPARATOR-END!!!!\nbar\n")).to eq "bar\n"
  end
end