require 'rubygems'
require 'bundler/setup'
require 'boxer'

%w{
  grape json date uri mongoid
}.each do |lib|
  require lib
end

module Doctothorpem
  class API < Grape::API
    version '1'
    prefix 'api'
    
    resource :users do
      get do
        User.all.map do |user|
          Boxer.ship(:user, user)
        end
      end
      
      get ':id' do
        user = User.where( :id => params[:id] ).first
        
        Boxer.ship(:user, user)
      end
    end
  end
end