#!/usr/bin/env ruby
# encoding: UTF-8

$0 = 'Math'
$LOAD_PATH.unshift ::File.dirname(__FILE__)

ENV['RACK_ENV'] ||= "development"

require 'rubygems'
require 'bundler'
require 'app'
require 'api/v1/index'

#configs
require 'config/mongoid'
require 'config/pony'

use Rack::Session::Cookie, :key => 'rack.session', :secret => ENV['SESSION_SECRET'] || 'octothorps'
use Rack::Flash

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