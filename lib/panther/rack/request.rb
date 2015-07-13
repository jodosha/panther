module Panther
  module Rack
    class Request
      POST = 'POST'.freeze
      attr_reader :input

      def initialize(raw, stream)
        @raw     = raw
        @stream  = stream
        @input   = StringIO.new('')
        @input.set_encoding('ASCII-8BIT') # Rack::Lint
      end

      def post?
        POST == request_method
      end

      def server_name
        @raw[':authority'].split(':').first
      end

      def server_port
        @raw[':authority'].split(':').last
      end

      def accept
        @raw['accept']
      end

      def accept_encoding
        @raw['accept-encoding']
      end

      def accept_language
        @raw['accept-language']
      end

      def cache_control
        @raw['cache-control']
      end

      def pragma
        @raw['pragma']
      end

      def user_agent
        @raw['user-agent']
      end

      def env
        {
          'REQUEST_METHOD'       => request_method,
          'SCRIPT_NAME'          => '',
          'PATH_INFO'            => location,
          'QUERY_STRING'         => location.split('?').last,
          'SERVER_NAME'          => server_name,
          'SERVER_PORT'          => server_port,
          'HTTP_USER_AGENT'      => user_agent,
          'HTTP_ACCEPT'          => accept,
          'HTTP_ACCEPT_ENCODING' => accept_encoding,
          'HTTP_ACCEPT_LANGUAGE' => accept_language,
          'CACHE_CONTROL'        => cache_control,
          'rack.version'         => ::Rack::VERSION,
          'rack.url_scheme'      => scheme,
          'rack.input'           => input,
          'rack.errors'          => StringIO.new(''),
          'rack.multithread'     => false,
          'rack.multiprocess'    => false,
          'rack.run_once'        => false,
          'rack.stream'          => @stream,
        }
      end

      protected

      def request_method
        @raw[':method']
      end

      def location
        @raw[':path']
      end

      def scheme
        @raw[':scheme']
      end
    end
  end
end
