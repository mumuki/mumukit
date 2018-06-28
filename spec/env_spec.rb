require_relative './spec_helper.rb'
require 'rack/test'

describe Mumukit::Env do
  include Rack::Test::Methods

  def app
    Class.new(Mumukit::ServerApp) do
      def runner
        @runner ||= Mumukit::Runner.create(config: {name: 'demo'})
      end
    end.new
  end

  it { expect { Mumukit::Env.base_url }.to raise_exception }

  it "should respond with the request's url" do
    get '/info'

    expect(last_response).to be_ok
    expect(Mumukit::Env.base_url).to eq 'http://example.org'
  end

  it "should add the repo_url property" do
    get '/info'

    expect(JSON.parse(last_response.body)["repo_url"]).to eq 'https://github.com/mumuki/mumuki-demo-runner'
  end

end
