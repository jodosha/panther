# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'panther/version'

Gem::Specification.new do |spec|
  spec.name          = "panther"
  spec.version       = Panther::VERSION
  spec.authors       = ["Luca Guidi"]
  spec.email         = ["me@lucaguidi.com"]

  spec.summary       = "HTTP/2 for Rack"
  spec.description   = "Experimental HTTP/2 server for Rack"
  spec.homepage      = "http://jodosha.github.io/panther"

  spec.metadata['allowed_push_host'] = "https://rubygems.org"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "http-2", "~> 0.8"
  spec.add_dependency "rack",   "~> 2.0"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake",      "~> 11.3"
  spec.add_development_dependency "rspec",     "~>  3.5"
  spec.add_development_dependency "aruba",     "~>  0.14"
end
