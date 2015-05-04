require 'sinatra/base'
require 'yaml'
require 'json'

class Mumukit::TestServerApp < Sinatra::Base
  configure do
    set :mumuki_url, 'http://mumuki.io'
  end

  configure :development do
    set :config_filename, 'config/development.yml'
  end

  configure :production do
    set :config_filename, 'config/production.yml'
  end

  config = YAML.load_file(settings.config_filename) rescue nil
  server = Mumukit::TestServer.new(config)

  post '/test' do
    JSON.generate(server.run!(JSON.parse(request.body.read)))
  end

  get '/*' do
    redirect settings.mumuki_url
  end
end
