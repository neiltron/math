ruby '2.1.3'
source "http://rubygems.org"
gem "rack"
gem 'rack-flash', :git => 'https://github.com/chy-causer/rack-flash'
gem 'rack-cors', :require => 'rack/cors'
gem 'rake'
gem "thin"
gem "sinatra"
gem "bson"
gem "bson_ext"
gem "mongoid"
gem 'mongoid_taggable_with_context', :git => 'https://github.com/neiltron/mongoid_taggable_with_context.git'
gem 'activesupport'
gem "haml"
gem 'json'
gem "metaid"
gem 'grape'
gem 'grape-swagger'
gem 'garner'
gem 'oauth2-provider', :git => 'https://github.com/neiltron/oauth2-provider.git'
gem 'mongoid_token'
gem 'boxer'
gem 'heroku'
gem 'pony'

group :production do
  gem 'rack-ssl'
  gem 'newrelic_rpm'
end

group :test do
  gem 'rack-test', :git => 'https://github.com/brynary/rack-test.git'
  gem 'rspec'
  gem 'rspec-core'
end