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

  config = YAML.load_file(settings.config_filename)
  compiler = TestCompiler.new(config)
  runner = TestRunner.new(config)

  helpers do
    def parse_test_body(request)
      compilation = JSON.parse request.body.read
      [compilation['test'], compilation['extra'], compilation['content']]
    end
  end

  post '/test' do
    begin
      req = parse_test_body request
      file = compiler.create_compilation_file!(*req)
      results = runner.run_test_file!(file)
      file.unlink
      JSON.generate(exit: results[1], out: results[0])
    rescue Exception => e
      JSON.generate(exit: 'failed', out: e.message)
    end
  end

  get '/*' do
    redirect settings.mumuki_url
  end
end
