require 'sinatra/base'
require 'yaml'
require 'json'

class Mumukit::ServerApp < Sinatra::Base
  configure do
    set :mumuki_url, 'http://mumuki.io'
    set :show_exceptions, false
    enable :logging
  end

  before do
    content_type 'application/json'
  end

  before do
    Mumukit::Env.env = env
    start_request!(parsed_request)
  end

  get '/info' do
    JSON.generate(info(request.url))
  end

  post '/test' do
    JSON.generate(test!(parsed_request))
  end

  post '/query' do
    JSON.generate(query!(parsed_request))
  end

  post '/try' do
    JSON.generate(try!(parsed_request))
  end

  get '/*' do
    redirect settings.mumuki_url
  end

  error StandardError do
    content_type :json
    status 500
    message = Mumukit::ContentType::Plain.format_exception env['sinatra.error']
    {exit: :errored, out: message}.to_json
  end

  required :runner

  private

  def info(url)
    runner.info.merge(url: url)
  end

  def start_request!(_request)
  end

  def parsed_request
    @parsed_request ||= parse_request(request)
  end

  def parse_request(sinatra_request)
    struct parse_request_headers(sinatra_request).merge(parse_request_body(sinatra_request))
  end

  def parse_request_headers(sinatra_request)
    {}
  end

  def parse_request_body(sinatra_request)
    JSON.parse(sinatra_request.body.read).tap do |it|
      I18n.locale = it['locale'] || :en
    end rescue {}
  end

  def test!(request)
    runner.run_test! request
  end

  def query!(request)
    runner.run_query! request
  end

  def try!(request)
    runner.run_try! request
  end
end
