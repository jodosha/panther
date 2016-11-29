require 'socket'
require 'openssl'
require 'http/2'
require 'rack'
require 'panther/rack/request'
require 'panther/rack/response'

module Panther
  class Logger
    def initialize(id)
      @id = id
    end

    def info(msg)
      puts "[Stream #{@id}]: #{msg}"
    end
  end

  class Server
    DRAFT        = 'h2'.freeze
    DEFAULT_HOST = 'localhost'.freeze
    DEFAULT_PORT = 7152

    def initialize(app, options = {})
      host = options.fetch(:host, DEFAULT_HOST)
      port = options.fetch(:port, DEFAULT_PORT)
      cert = options.fetch(:cert, nil)
      key  = options.fetch(:key,  nil)

      @server = TCPServer.new(host, port)

      if (ssl = cert && key)
        context      = OpenSSL::SSL::SSLContext.new
        context.cert = OpenSSL::X509::Certificate.new(File.open(cert))
        context.key  = OpenSSL::PKey::RSA.new(File.open(key))

        context.npn_protocols = [DRAFT]
        context.ssl_version   = :SSLv23

        @server = OpenSSL::SSL::SSLServer.new(@server, context)
        @server.start_immediately = true
      end

      @app = app

      $stdout.puts "Panther: listening http#{ssl ? 's' : nil}://#{host}:#{port}"
    end

    def run
      app = @app

      loop do
        # process @server.accept
        sock = @server.accept
        puts 'New TCP connection!'

        conn = HTTP2::Server.new
        conn.on(:frame) do |bytes|
          # puts "Writing bytes: #{bytes.unpack("H*").first}"
          sock.write bytes
        end
        conn.on(:frame_sent) do |frame|
          puts "Sent frame: #{frame.inspect}"
        end
        conn.on(:frame_received) do |frame|
          puts "Received frame: #{frame.inspect}"
        end

        conn.on(:stream) do |stream|
          log = Logger.new(stream.id)
          req = nil

          stream.on(:active) { log.info 'cliend opened new stream' }
          stream.on(:close)  { log.info 'stream closed' }

          stream.on(:headers) do |h|
            req = Panther::Rack::Request.new(Hash[*h.flatten], stream)
            log.info "request headers: #{h}"
          end

          stream.on(:data) do |d|
            log.info "payload chunk: <<#{d}>>"
            req.input << d
          end

          stream.on(:half_close) do
            log.info 'client closed its end of the stream'
            response = Panther::Rack::Response.new(*app.call(req.env))
            stream.headers(response.stream_headers, end_stream: false)

            # split response into multiple DATA frames
            body = response.__send__(:body).string
            stream.data(body.slice!(0, 5), end_stream: false)
            stream.data(body)

            # response.buffer do |chunk|
            #   stream.data(chunk, end_stream: false)
            # end
            # stream.data("")
          end
        end

        while !sock.closed? && !(sock.eof? rescue true) # rubocop:disable Style/RescueModifier
          data = sock.readpartial(1024)
          # puts "Received bytes: #{data.unpack("H*").first}"

          begin
            conn << data
          rescue => e
            puts "Exception: #{e}, #{e.message} - closing socket."
            sock.close
          end
        end
      end
    end
  end
end
