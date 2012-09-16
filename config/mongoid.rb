require 'uri'
require 'mongoid'
require 'garner'

module Mongoid
  module Document
    include Garner::Mixins::Mongoid::Document
  end
end

#mongo connects
if ENV['RACK_ENV'] == 'production'
  Mongoid.load!("config/mongoid.yml", :production)
elsif ENV['RACK_ENV'] == 'development'
	Mongoid.load!("config/mongoid.yml", :development)
end
