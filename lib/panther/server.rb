require 'socket'
require 'openssl'
require 'http/2'
require 'rack'
require 'panther/rack/request'

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
      server = TCPServer.new(options.fetch(:host, DEFAULT_HOST),
                             options.fetch(:port, DEFAULT_PORT))

      context      = OpenSSL::SSL::SSLContext.new
      context.cert = OpenSSL::X509::Certificate.new(File.open(options.fetch(:cert)))
      context.key  = OpenSSL::PKey::RSA.new(File.open(options.fetch(:key)))

      context.npn_protocols = [DRAFT]
      context.ssl_version   = :SSLv23

      @server = OpenSSL::SSL::SSLServer.new(server, context)
      @server.start_immediately = true
      @app    = app
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
            app.call(req.env)
            # response = nil
            # if req.post?
            #   log.info "Received POST request, payload: #{req.input}"
            #   response = "Hello HTTP 2.0! POST payload: #{req.input}"
            # else
            #   log.info 'Received GET request'
            #   response = 'Hello HTTP 2.0! GET request'
            # end

            # stream.headers({
            #   ':status' => '200',
            #   'content-length' => response.bytesize.to_s,
            #   'content-type' => 'text/plain',
            # }, end_stream: false)

            # # split response into multiple DATA frames
            # stream.data(response.slice!(0, 5), end_stream: false)
            # stream.data(response)
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
