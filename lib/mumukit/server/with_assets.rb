module Mumukit::Server::WithAssets
  extend ActiveSupport::Concern

  included do
    register Sinatra::CrossOrigin

    configure do
      set :allow_origin, '*'
    end
  end

  class_methods do

    def get_asset(route, absolute_path, type)
      get "/assets/#{route}" do
        cross_origin
        send_file absolute_path, type: type
      end
    end

  end
end

