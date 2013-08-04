require 'spec_helper'

describe Math::API do
  include Rack::Test::Methods

  def app
    Math::API
  end

  before do
    @user = User.create(email: 'fake@email.com', password: 'fakepass')
    @user.confirm!

    @user.accesskey = AccessKey.new
    @accesskey = @user.accesskey.token.to_s
  end


  context "unauthenticated" do
    it "users/profile" do
      get "/api/1/users/profile.json"
      last_response.status.should == 401
      last_response.body.should == { error: "Unauthorized" }.to_json
    end
  end

  context "authenticated" do
    it 'users/profile' do
      get "api/1/users/profile.json?accesskey=#{@accesskey}"

      last_response.status.should == 200
    end

    it 'users/:user_id/profile' do
      get "api/1/users/#{@user.id.to_s}.json?accesskey=#{@accesskey}"

      last_response.status.should == 200
    end
  end

end
