require 'spec_helper'

describe Math::API do
  include Rack::Test::Methods

  def app
    Math::API
  end

  before(:all) do
    @user = User.create(email: 'fake@email.com', password: 'fakepass')
    @user.confirm!

    @accesskey = @user.accesskey.token.to_s
  end


  context "unauthenticated" do
    it "users/profile" do
      get "/api/1/users/profile.json"
      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq({ error: "Unauthorized" }.to_json)
    end
  end

  context "authenticated" do
    it 'users/profile' do
      get "api/1/users/profile.json?accesskey=#{@accesskey}"

      expect(last_response.status).to eq(200)
    end

    it 'users/:user_id/profile' do
      get "api/1/users/#{@user.id.to_s}.json?accesskey=#{@accesskey}"

      expect(last_response.status).to eq(200)
    end
  end

end
