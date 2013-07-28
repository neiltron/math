require 'uri'
require 'mongoid'
require 'garner'

module Mongoid
  module Document
    include Garner::Mixins::Mongoid::Document
  end
end

#mongo connects
Mongoid.load!("config/mongoid.yml", ENV['RACK_ENV'].to_sym)
