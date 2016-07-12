require 'sinatra/base'
require 'yaml'
require 'json'


class Mumukit::Server::App < Sinatra::Base
  configure do
    set :mumuki_url, 'http://mumuki.io'
    set :show_exceptions, :after_handler
    enable :logging
  end

  configure :development do
    set :config_filename, 'config/development.yml'
  end

  configure :production do
    set :config_filename, 'config/production.yml'
  end

  runtime_config = YAML.load_file(settings.config_filename) rescue nil

  Mumukit.configure_runtime(runtime_config)

  set :server, Mumukit::Server::TestServer.new

  before do
    content_type 'application/json'
  end

  before do
    Mumukit::Env.env = env
    server.start_request!(parse_request)
  end

  helpers do
    def server
      settings.server
    end

    def parse_request
      @parsed_request ||= server.parse_request(request)
    end
  end

  get '/info' do
    JSON.generate(server.info(request.url))
  end

  post '/test' do
    JSON.generate(server.test!(parse_request))
  end

  post '/query' do
    JSON.generate(server.query!(parse_request))
  end

  get '/*' do
    redirect settings.mumuki_url
  end

  error StandardError do
    content_type :json
    status 200

    message = Mumukit::ContentType::Plain.format_exception env['sinatra.error']
    logger.error "Unhandled error #{message}"

    {status: :errored, exit: message}.to_json
  end
end
