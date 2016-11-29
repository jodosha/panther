module Panther
  module Rack
    class Response
      STATUS = ':status'.freeze

      CONTENT_LENGTH = 'content-length'.freeze
      CONTENT_TYPE   = 'content-type'.freeze

      DEFAULT_CONTENT_TYPE = 'text/plain'.freeze

      CHUNK_MAX_LEN = 1024

      def initialize(status, headers, body)
        @status  = status.to_s
        @headers = prepare_headers(headers, body.first)
        @body    = StringIO.new(body.first)
      end

      def stream_headers
        # http-2 gem expects status to be first
        Hash[STATUS => status].merge(headers)
      end

      def buffer
        body.rewind
        while !body.closed? && !(body.eof? rescue true) # rubocop:disable Style/RescueModifier
          yield body.readpartial(CHUNK_MAX_LEN)
        end
      end

      private

      attr_reader :status, :headers, :body

      def prepare_headers(raw, body)
        result = raw.each_with_object({}) { |(k, v), ret| ret[k.downcase] = v }
        result[CONTENT_LENGTH] ||= body.bytesize.to_s
        result[CONTENT_TYPE]   ||= DEFAULT_CONTENT_TYPE
        result
      end
    end
  end
end
