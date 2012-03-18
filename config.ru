#!/usr/bin/env ruby
# encoding: UTF-8

$0 = 'Doctothorpem'
$LOAD_PATH.unshift ::File.dirname(__FILE__)

ENV['RACK_ENV'] ||= "development"

require 'rubygems'
require 'bundler'
require 'app'
require 'api/v1/index'

#configs
require 'config/mongoid'

use Rack::Session::Cookie, :key => 'rack.session', :secret => ENV['SESSION_SECRET'] || 'octothorps'
use Rack::Flash

Bundler.setup
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

run Rack::Cascade.new([
	Doctothorpem::API,
	Doctothorpem::Web
])