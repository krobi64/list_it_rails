require 'rails_helper'

RSpec.describe "Lists", type: :request do

  describe "GET /index" do
    it "returns http success" do
      get "/lists/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/lists/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/lists/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /delete" do
    it "returns http success" do
      get "/lists/delete"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /share" do
    it "returns http success" do
      get "/lists/share"
      expect(response).to have_http_status(:success)
    end
  end

end
