require_relative './spec_helper.rb'
require 'rack/test'

describe Mumukit do
  include Rack::Test::Methods

  def app
    Mumukit::Server::App.new
  end

  it { expect { Mumukit.runner_url }.to raise_exception(NoMethodError) }

  context '/info' do
    it "should respond with the request's url" do
      get '/info'

      expect(last_response).to be_ok
      expect(Mumukit.runner_url).to eq 'http://example.org'
    end

    it 'should add the repo_url property' do
      get '/info'

      expect(JSON.parse(last_response.body)['repo_url']).to eq 'https://github.com/mumuki/mumuki-demo-runner'
    end
  end

  context '/test' do
    it 'should throw an error if the request is not well formed' do
      post '/test', '{ BAD&JSON: 3 }'

      response = JSON.parse(last_response.body)
      expect(response['exit']).to eq 'errored'
      expect(response['out']).to match /Error parsing request body\. Cause: unexpected token at '{ BAD.JSON: 3 }'/
    end

    it 'should throw an error if the request has a non-existing locale' do
      post '/test', '{ "locale": "jojo" }'

      response = JSON.parse(last_response.body)
      expect(response['exit']).to eq 'errored'
      expect(response['out']).to include "Error parsing request body. Cause: \"jojo\" is not a valid locale"
    end
  end

end
