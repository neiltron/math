require 'rubygems'
require 'bundler'

ENV["RACK_ENV"] ||= 'test'

require 'rack/test'

Bundler.require :default, ENV['RACK_ENV']
require File.expand_path("../../config/mongoid", __FILE__)
require File.expand_path("../../models/init", __FILE__)
require File.expand_path("../../api/index", __FILE__)

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec
end