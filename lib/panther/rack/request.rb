module Panther
  module Rack
    class Request
      REQUEST_METHOD       = 'REQUEST_METHOD'.freeze
      SCRIPT_NAME          = 'SCRIPT_NAME'.freeze
      PATH_INFO            = 'PATH_INFO'.freeze
      QUERY_STRING         = 'QUERY_STRING'.freeze
      SERVER_NAME          = 'SERVER_NAME'.freeze
      SERVER_PORT          = 'SERVER_PORT'.freeze
      HTTP_USER_AGENT      = 'HTTP_USER_AGENT'.freeze
      HTTP_ACCEPT          = 'HTTP_ACCEPT'.freeze
      HTTP_ACCEPT_ENCODING = 'HTTP_ACCEPT_ENCODING'.freeze
      HTTP_ACCEPT_LANGUAGE = 'HTTP_ACCEPT_LANGUAGE'.freeze
      HTTP_CACHE_CONTROL   = 'CACHE_CONTROL'.freeze
      RACK_VERSION         = 'rack.version'.freeze
      RACK_URL_SCHEME      = 'rack.url_scheme'.freeze
      RACK_INPUT           = 'rack.input'.freeze
      RACK_ERRORS          = 'rack.errors'.freeze
      RACK_MULTITHREAD     = 'rack.multithread'.freeze
      RACK_MULTIPROCESS    = 'rack.multiprocess'.freeze
      RACK_RUN_ONCE        = 'rack.run_once'.freeze
      RACK_STREAM          = 'rack.stream'.freeze

      AUTHORITY       = ':authority'.freeze
      METHOD          = ':method'.freeze
      PATH            = ':path'.freeze
      SCHEME          = ':scheme'.freeze
      ACCEPT          = 'accept'.freeze
      ACCEPT_ENCODING = 'accept-encoding'.freeze
      ACCEPT_LANGUAGE = 'accept-language'.freeze
      CACHE_CONTROL   = 'cache-control'.freeze
      PRAGMA          = 'pragma'.freeze
      USER_AGENT      = 'user-agent'.freeze

      INPUT_ENCODING         = 'ASCII-8BIT'.freeze
      AUTHORITY_SEPARATOR    = ':'.freeze
      QUERY_STRING_SEPARATOR = '?'.freeze

      attr_reader :input

      def initialize(raw, stream)
        @raw     = raw
        @stream  = stream
        @input   = StringIO.new('')
        @input.set_encoding(INPUT_ENCODING) # Rack::Lint
      end

      def server_name
        server_and_port.first
      end

      def server_port
        server_and_port.last
      end

      def server_and_port
        @raw[AUTHORITY].split(AUTHORITY_SEPARATOR)
      end

      def accept
        @raw[ACCEPT]
      end

      def accept_encoding
        @raw[ACCEPT_ENCODING]
      end

      def accept_language
        @raw[ACCEPT_LANGUAGE]
      end

      def cache_control
        @raw[CACHE_CONTROL]
      end

      def pragma
        @raw[PRAGMA]
      end

      def user_agent
        @raw[USER_AGENT]
      end

      def env
        {
          REQUEST_METHOD       => request_method,
          SCRIPT_NAME          => '',
          PATH_INFO            => location,
          QUERY_STRING         => query_string,
          SERVER_NAME          => server_name,
          SERVER_PORT          => server_port,
          HTTP_USER_AGENT      => user_agent,
          HTTP_ACCEPT          => accept,
          HTTP_ACCEPT_ENCODING => accept_encoding,
          HTTP_ACCEPT_LANGUAGE => accept_language,
          HTTP_CACHE_CONTROL   => cache_control,
          RACK_VERSION         => ::Rack::VERSION,
          RACK_URL_SCHEME      => scheme,
          RACK_INPUT           => input,
          RACK_ERRORS          => StringIO.new(''),
          RACK_MULTITHREAD     => false,
          RACK_MULTIPROCESS    => false,
          RACK_RUN_ONCE        => false,
          RACK_STREAM          => @stream,
        }
      end

      protected

      def request_method
        @raw[METHOD]
      end

      def location
        @raw[PATH]
      end

      def scheme
        @raw[SCHEME]
      end

      def query_string
        _, qs = *location.split(QUERY_STRING_SEPARATOR)
        qs || ""
      end
    end
  end
end
