require 'uri'
require 'mongoid'

#mongo connects
configure :production do
	if ENV["MONGOHQ_URL"]
  		mongo_uri = URI.parse(ENV["MONGOHQ_URL"])
  		ENV['MONGOID_HOST'] = mongo_uri.host
  		ENV['MONGOID_PORT'] = mongo_uri.port.to_s
  		ENV['MONGOID_USERNAME'] = mongo_uri.user
  		ENV['MONGOID_PASSWORD'] = mongo_uri.password
  		ENV['MONGOID_DATABASE'] = mongo_uri.path.gsub("/", "")
	end

	Mongoid.configure do |config|
		config.skip_version_check = true
		config.master = Mongo::Connection.from_uri(ENV['MONGOHQ_URL']).db(ENV['MONGOID_DATABASE'])
	end
end

configure :development do
	Mongoid.configure do |config|
		config.master = Mongo::Connection.new.db("doctothorpem")
	end
end
