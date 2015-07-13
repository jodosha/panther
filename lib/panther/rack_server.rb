require 'rack'
require 'panther/server'
require 'panther/rack/request'

module Panther
  class RackServer < Server

    # def run
    #   loop do
    #     socket = @server.accept
    #     Panther::Rack::Request.new(socket)

# #         @app.call(
# #           Panther::Rack::Request.new(socket).env
# #         )
    #   end
    # end

    protected

#     def process(socket)
#       @app.call(
#         Panther::Rack::Request.new(socket).env
#       )
#     end
  end
end

module Rack
  module Handler
    class Panther
      def self.run(app, options = {})
        ::Panther::RackServer.new(app, options).run
      end
    end
  end
end

Rack::Handler.register('panther', 'Rack::Handler::Panther')
