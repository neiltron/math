%w{
  rubygems bundler/setup grape grape-swagger garner json date uri mongoid boxer
}.each do |lib|
  require lib
end

require_relative 'v1/index.rb'

module Math
  class API < Grape::API
    prefix 'api'

    mount Math::V1

    add_swagger_documentation({ :hide_documentation_path => true, :api_version => '1' })
  end
end