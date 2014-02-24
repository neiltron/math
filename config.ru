#!/usr/bin/env ruby
# encoding: UTF-8

$0 = 'Math'
$LOAD_PATH.unshift ::File.dirname(__FILE__)

ENV['RACK_ENV'] ||= "development"

if ENV['RACK_ENV'] == 'development'
  log = File.new("log/development.log", "a+")
  $stdout.reopen(log)
  $stderr.reopen(log)
end

require 'rubygems'
require 'bundler'
require 'rack/cors'

use Rack::Cors do
  allow do
    origins '*'
    resource '*',
      headers: ['Origin', 'Accept', 'Content-Type', 'X-CSRF-Token'],
      methods: [:get, :post, :put, :delete, :options]
  end
end

require 'app'
require 'api/index'
require 'oauth2/provider'

#configs
require 'config/mongoid'
require 'config/pony'

use Rack::Session::Cookie, :key => 'rack.session', :secret => ENV['SESSION_SECRET'] || 'octothorps'
use Rack::Flash

use Rack::Deflater

OAuth2::Provider.realm = 'Mathematics'

PERMISSIONS = {
  'read_records' => 'Read all items and records',
  'write_records' => 'Create new records'
}
ERROR_RESPONSE = JSON.unparse('error' => 'No soup for you!')


#only force ssl in production
if ENV['RACK_ENV'] == 'production'
  require 'rack/ssl'
  use Rack::SSL
end

Bundler.setup
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

run Rack::Cascade.new([
	Math::API,
	Math::Web
])