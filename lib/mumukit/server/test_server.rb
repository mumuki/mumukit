require 'yaml'
require 'ostruct'

class Mumukit::Server::TestServer

  include Mumukit::WithContentType

  def current_runner
    Mumukit.current_runner
  end

  def info(url)
    current_runner.info.merge(url: url)
  end


  def start_request!(_request)
  end

  def parse_request(sinatra_request)
    OpenStruct.new parse_request_headers(sinatra_request).merge(parse_request_body(sinatra_request))
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
    current_runner.run_test! request
  end

  def query!(request)
    current_runner.run_query! request
  end

  def try!(request)
    current_runner.run_try! request
  end
end
