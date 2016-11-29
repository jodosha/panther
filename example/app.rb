module Middleware
  class Runtime
    FORMAT_STRING = '%0.6f'.freeze

    def initialize(app)
      @app = app
    end

    def call(env)
      starting = Time.now.to_f
      status, header, body = @app.call(env)
      ending = Time.now.to_f

      header["X-Runtime"] = FORMAT_STRING % (ending - starting)

      [status, header, body]
    end
  end
end

class MyApp
  def call(env)
    [200, { "Content-Length" => "8", "Content-Type" => "text/plain" }, ["Hello H2"]]
  end
end
