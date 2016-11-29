require 'panther'
require './app'

use Middleware::Runtime
run MyApp.new
