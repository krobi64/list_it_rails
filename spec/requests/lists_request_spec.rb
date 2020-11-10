require 'rails_helper'

RSpec.describe "Lists", type: :request do

  context 'without a JWT' do
    it 'returns a 401' do
      get '/lists/index'
      expect(response).to have_http_status(:unauthorized)
      result = JSON.parse response.body
      expect(result['status']).to eq('error')
      expect(result['payload']['token']).to eq('Missing token')
    end
  end

  context 'with an Invalid JWT' do
    it 'returns a 401' do
      headers = {'AUTHORIZATION': 'token 1234'}
      get '/lists/index', headers: headers
      result = JSON.parse response.body
      expect(result['status']).to eq('error')
      expect(result['payload']['token']).to eq('Invalid token')
    end
  end

  # describe "GET /index" do
  #   it "returns http success" do
  #     get "/lists/index"
  #     expect(response).to have_http_status(:success)
  #   end
  # end
  #
  # describe "GET /create" do
  #   it "returns http success" do
  #     get "/lists/create"
  #     expect(response).to have_http_status(:success)
  #   end
  # end
  #
  # describe "GET /update" do
  #   it "returns http success" do
  #     get "/lists/update"
  #     expect(response).to have_http_status(:success)
  #   end
  # end
  #
  # describe "GET /delete" do
  #   it "returns http success" do
  #     get "/lists/delete"
  #     expect(response).to have_http_status(:success)
  #   end
  # end
  #
  # describe "GET /share" do
  #   it "returns http success" do
  #     get "/lists/share"
  #     expect(response).to have_http_status(:success)
  #   end
  # end

end
