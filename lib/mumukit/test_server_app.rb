require 'sinatra/base'
require 'yaml'
require 'json'

require 'i18n'
require 'i18n/backend/fallbacks'

class Mumukit::TestServerApp < Sinatra::Base
  configure do
    set :mumuki_url, 'http://mumuki.io'

    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(settings.root, 'locales', '*.yml')]
    I18n.backend.load_translations
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
    r = JSON.parse(request.body.read)
    I18n.locale = r['locale'] || :en
    JSON.generate(server.run!(r))
  end

  get '/*' do
    redirect settings.mumuki_url
  end
end
