require 'pathname'

module Panther
  module Rack
    class Builder
      def self.build(config)
        new(config).to_app
      end

      def initialize(config)
        @use    = []
        @config = Pathname.new(config).realpath
        eval(@config.read) # rubocop:disable Lint/Eval
      end

      def use(middleware, *args, &block)
        @use << [middleware, *args, block]
      end

      def run(app) # rubocop:disable Style/TrivialAccessors
        @run = app
      end

      def to_app
        @use.reverse.inject(@run) do |app, (m, args, block)|
          m.new(app, *args, &block)
        end
      end
    end
  end
end
