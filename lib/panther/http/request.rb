require 'http/2'

module Panther
  module HTTP
    class Request
      EVENTS = {frame: true, frame_sent: true, frame_received: true, stream: true}

      def initialize(socket)
        @socket     = socket
        @connection = HTTP2::Server.new
      end

      def read
        while !@socket.closed? && !(@socket.eof? rescue true)
          data = @socket.readpartial(1024)

          # puts "Received bytes: #{data.unpack("H*").first}"
          begin
            @connection << data
          rescue => e
            puts "Exception: #{e}, #{e.message} - closing socket."
            @socket.close
          end
        end
      end

      def on(event, &blk)
        event = event.to_sym
        EVENTS.fetch(event) { raise "Unknown event: #{ event }" }

        @connection.on(event, &blk)
      end
    end
  end
end
