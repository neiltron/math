require 'spec_helper'

describe Math::API do
  include Rack::Test::Methods

  def app
    Math::API
  end

  context "unauthenticated" do
    it "users/profile" do
      get "/api/1/users/profile.json"
      last_response.status.should == 401
      last_response.body.should == { error: "Unauthorized" }.to_json
    end
  end

end
