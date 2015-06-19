$:.unshift File.expand_path("../lib", __FILE__)
require "hiera/backend/redis_backend"

Gem::Specification.new do |s|
  s.version = Hiera::Backend::Redis_backend::VERSION
  s.name = "hiera-redis"
  s.email = "heira-redis@reliantsecurity.com"
  s.authors = "Adam Kosmin c/o Reliant Security, Inc."
  s.summary = "A Redis backend for Hiera."
  s.description = "Allows hiera functions to pull data from a Redis database."
  s.has_rdoc = false
  s.homepage = "http://github.com/reliantsecurity/hiera-redis"
  s.license = "GPL-3"
  s.add_dependency 'hiera', '>= 1.0'
  s.files = Dir["lib/**/*.rb"]
  s.files += ["COPYING"]
end
