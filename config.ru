#!/usr/bin/env ruby
# encoding: UTF-8

$0 = 'Math'
$LOAD_PATH.unshift ::File.dirname(__FILE__)

require 'config/environment'

if ENV['RACK_ENV'] == 'development'
  log = File.new("log/development.log", "a+")
  $stdout.reopen(log)
  $stderr.reopen(log)
end

require 'rack/cors'
require 'app'
require 'api/index'

use Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: ['Origin', 'Accept', 'Content-Type', 'X-CSRF-Token'],
      methods: [:get, :post, :put, :delete, :options]
  end
end

use Rack::Session::Cookie, :key => 'rack.session', :secret => ENV['SESSION_SECRET'] || 'octothorps'
use Rack::Flash
use Rack::Deflater

#only force ssl in production
if ENV['RACK_ENV'] == 'production'
  require 'rack/ssl'
  use Rack::SSL
end

run Rack::Cascade.new([
	Math::API,
	Math::Web
])
