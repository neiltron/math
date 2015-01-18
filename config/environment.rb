$stdout.sync = true

ENV['RACK_ENV'] ||= "development"

require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require(:default, ENV['RACK_ENV'].to_sym)

%w( mongoid pony oauth ).each do |config|
  require_relative config
end

require_relative "../models/init"
