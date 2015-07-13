require 'lotus/router'
require 'lotus/controller'

module Lotus
  module Action
    module HTTP2
      private

      def body=(value)
        @_body = value.to_s
      end

      def stream
        @_env['rack.stream']
      end

      def promise
        @_env['rack.promise']
      end

      def finish
        super

        head = {
          ":status" => '200',
          ":path"   => "/other_resource",
          "content-type" => "text/plain"
        }

        # require 'byebug'
        # byebug
        stream.promise(head) do |push|
          # push.headers({ 'X-Promise' => 'OK' })
          # push.data('hello')
        end

        stream.headers(
          headers.merge(
            ':status'        => (@_status || 200).to_s,
            'content-length' => @_body.bytesize.to_s,
            'content-type'   => content_type),
            end_stream: false
        )

        # promise.data('world')

        # split response into multiple DATA frames
        stream.data(@_body.slice!(0, 5), end_stream: false)
        stream.data(@_body)
      end

      def response
        [-1, {}, nil]
      end
    end
  end
end

class MyAction
  include Lotus::Action
  prepend Lotus::Action::HTTP2

  def call(env)
    if env['PATH_INFO'] == '/'
      puts 'Received GET request on /'
      self.body = 'Hello HTTP 2.0! GET request'
      # puts "Received POST request, payload: #{env['rack.input']}"
      # self.body = "Hello HTTP 2.0! POST payload: #{env['rack.input']}"
    else
      puts 'Received GET request'
      self.body = 'Daje'
    end
  end
end

class MyAction2
  include Lotus::Action
  prepend Lotus::Action::HTTP2

  def call(env)
    require 'byebug'
    byebug
    self.body = '2'
  end
end

class MyApp
  def initialize
    @router = Lotus::Router.new do
      get '/',    to: MyAction.new
      get '/foo', to: MyAction2.new
    end
  end

  def call(env)
    require 'byebug'
    byebug
    @router.call(env)
  end
end
