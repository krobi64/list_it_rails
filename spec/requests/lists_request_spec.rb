require 'rails_helper'
require_relative '../support/shared_response'

RSpec.describe "Lists", type: :request do

  let(:user) { create :user }
  let(:token) { JsonWebToken.encode(id: user.id) }
  let(:header) {
    {
        AUTHORIZATION: "token #{token}"
    }
  }
  let(:response_body) { JSON.parse response.body }

  context 'without a JWT' do
    it 'returns a 401' do
      get '/lists'
      expect(response).to have_http_status(:unauthorized)
      expect(response_body['status']).to eq('error')
      expect(response_body['payload']['token']).to eq('Missing token')
    end
  end

  context 'with an Invalid JWT' do
    it 'returns a 401' do
      headers = {'AUTHORIZATION': 'token 1234'}
      get '/lists/index', headers: headers
      expect(response_body['status']).to eq('error')
      expect(response_body['payload']['token']).to eq('Invalid token')
    end
  end

  describe 'POST /lists' do
    before do
      post '/lists', params: body, headers: header
    end

    context 'with a name' do
      let(:body) { {list: {name: 'A list'}} }

      it_behaves_like 'a successful request without a body'
    end

    context 'without a list name' do
      let(:body) { {list: { name: '' }} }

      it 'returns a 422 with an error' do
        post '/lists', params: body, headers: header
        expect(response).to have_http_status(:conflict)
        expect(response_body['status']).to eq('error')
        expect(response_body['payload']['name']).to eq(["can't be blank"])
      end
    end
  end

  describe 'GET /lists' do
    context 'with no lists assigned' do
      before do
        get '/lists', headers: header
      end

      it_behaves_like 'a successful request'

      it 'returns an empty array as a payload' do
        expect(response_body['payload']).to eq([])
      end
    end

    context 'with only lists owned by the current user' do
      before do
        user = create(:user_with_lists)
        @user_id = user.id
        token = JsonWebToken.encode(id: user.id)
        header = { AUTHORIZATION: "token #{token}"}
        get '/lists', headers: header
      end

      it_behaves_like 'a successful request'

      it 'returns a payload with an array of two lists' do
        expect(response_body['payload'].size).to eq(2)
      end

      it 'returns only lists owned by the current_user' do
        expect(response_body['payload'].all? { |list| list['user_id'] == @user_id}).to eq(true)
      end
    end
  end


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
