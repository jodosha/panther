module Rack
  module Handler
    class Panther
      def self.run(app, options = {})
        ::Panther::Server.new(app, options).run
      end
    end
  end
end

Rack::Handler.register('panther', 'Rack::Handler::Panther')
