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


  helpers do
    def parse_test_body(request)
      body = JSON.parse request.body.read
    end

    def run_tests!(config, test, extra, content)
      compiler = TestCompiler.new(config)
      runner = TestRunner.new(config)

      file = compiler.create_compilation_file!(test, extra, content)
      runner.run_test_file!(file)
    ensure
      file.unlink if file
    end

    def run_expectations!(config, expectations, content)
      expectations_runner = ExpectationsRunner.new(config)

      if expectations
        expectations_runner.run_expectations!(expectations, content)
      else
        []
      end
    end
  end

  post '/test' do
    begin
      req = parse_test_body request
      content = req['content']

      test_results = run_tests! config, body['test'], body['extra'], content
      expectation_results = run_expectations! config, req['expectations'], content

      JSON.generate(exit: test_results[1], out: test_results[0], expectationResults: expectation_results)
    rescue Exception => e
      JSON.generate(exit: 'failed', out: e.message)
    end
  end

  get '/*' do
    redirect settings.mumuki_url
  end
end
