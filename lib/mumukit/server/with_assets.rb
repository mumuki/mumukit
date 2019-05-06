require 'sinatra/base'
require 'mime/types'
require 'sinatra/cross_origin'

module Mumukit::Server::WithAssets
  extend ActiveSupport::Concern

  included do
    register Sinatra::CrossOrigin

    configure do
      set :allow_origin, '*'
    end
  end

  class_methods do
    def get_asset(route, absolute_path, type=nil)
      type ||= infer_asset_type_from(route)
      get "/assets/#{route}" do
        cross_origin
        send_file absolute_path, type: type
      end
    end

    def infer_asset_type_from(route)
      extension = File.extname(route)
      MIME::Types.type_for(extension).first.content_type
    end

    def get_local_asset(route, path, type=nil)
      get_asset route, File.join(local_asset_dir, '..', path), type
    end

    def local_asset_dir
      @local_asset_dir ||= File.dirname caller[1].split(':')[0]
      # Had to use caller[1] because the first entry of the stack is from this file
    end
  end
end

