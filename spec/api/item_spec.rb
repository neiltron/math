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
    it "users/:user_id/items" do
      get "/api/1/users/#{@user.id.to_s}/items.json"
      last_response.status.should == 401
      last_response.body.should == { error: "Unauthorized" }.to_json
    end
  end

  context "authenticated" do
    it 'users/:user_id/items' do
      get "api/1/users/#{@user.id.to_s}/items.json?accesskey=#{@accesskey}"

      last_response.status.should == 200
      JSON.parse(last_response.body).should == []
    end

    it 'users/:user_id/records' do
      post "api/1/users/#{@user.id.to_s}/records.json?accesskey=#{@accesskey}", {
        item_name: 'something',
        amount: 5
      }

      last_response.status.should == 201
    end

    it 'users/:user_id/items' do
      get "api/1/users/#{@user.id.to_s}/items.json?accesskey=#{@accesskey}"

      last_response.status.should == 200
      json_response = JSON.parse(last_response.body)
      json_response.count.should == 1
      @item = json_response.first
    end

    it 'users/:user_id/items/:item_id/records' do
      get "api/1/users/#{@user.id.to_s}/items.json?accesskey=#{@accesskey}"

      last_response.status.should == 200
      json_response = JSON.parse(last_response.body)
      @item = json_response.first

      get "api/1/users/#{@user.id.to_s}/items/#{@item['id'].to_s}/records.json?accesskey=#{@accesskey}"
      json_response = JSON.parse(last_response.body)
      json_response['values'].last[1].to_i.should > 0
    end
  end

end
