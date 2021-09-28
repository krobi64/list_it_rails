# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Lists", type: :request do

  let(:user) { create :user }
  let(:token) { JsonWebToken.encode(id: user.id) }
  let(:header) {
    {
        AUTHORIZATION: "token #{token}"
    }
  }
  let(:response_body) { JSON.parse response.body }

  context 'without a valid JWT' do
    before do
      get '/lists'
    end
    it_behaves_like 'a request that fails without a valid JWT'
  end

  describe 'POST /lists' do
    before do
      post '/lists', params: body, headers: header
    end

    context 'with a name' do
      let(:body) { {list: {name: 'A list'}} }

      it_behaves_like 'a successful request without a body'
      it 'returns a created status' do
        expect(response).to have_http_status(:created)
      end
    end

    context 'without a list name' do
      let(:body) { {list: { name: '' }} }
      before do
        post '/lists', params: body, headers: header
      end

      it_behaves_like 'an invalid request'

      it 'returns a status of :bad_request' do
        expect(response).to have_http_status(:bad_request)
      end

      it "returns an error message #{LIST_NAME_BLANK}" do
        expect(response_body['payload']['name']).to eq([LIST_NAME_BLANK])
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
        user = create(:user)
        2.times { |i| user.all_lists.create(name: "List #{i}", user: user)}
        @created_by = user.full_name
        token = JsonWebToken.encode(id: user.id)
        header = { AUTHORIZATION: "token #{token}"}
        get '/lists', headers: header
      end

      it_behaves_like 'a successful request'
      it 'returns a payload with an array of two lists' do
        expect(response_body['payload'].size).to eq(2)
      end

      it 'returns only lists owned by the current_user' do
        expect(response_body['payload'].all? { |list| list['created_by'] == @created_by}).to eq(true)
      end
    end
  end

  describe 'GET /lists/:id' do
    before do
      @user = create(:user)
      2.times { |i| @user.all_lists.create(name: "List #{i}", user: @user)}
      token = JsonWebToken.encode(id: @user.id)
      @header = { AUTHORIZATION: "token #{token}"}
    end

    context 'with an existing list' do
      before do
        @list_id = @user.lists.first.id
        get "/lists/#{@list_id}", headers: @header
      end

      it_behaves_like 'a successful request'

      it 'returns a success status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the list object' do
        expect(response_body['payload']['id']).to eq(@list_id)
      end
    end

    context 'with a non-existing list id' do
      before do
        get '/lists/999', headers: @header
      end

      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a not found message' do
        expect(response_body['payload']).to eq(LIST_NOT_FOUND)
      end
    end
  end

  describe "PUT /lists/:id" do
    let(:list_params) { {list: {name: 'altered list name'}} }

    before do
      @user = create(:user)
      2.times { |i| user.all_lists.create(name: "List #{i}", user: @user)}
      token = JsonWebToken.encode(id: @user.id)
      @header = { AUTHORIZATION: "token #{token}"}
    end

    context 'with an invalid list id' do
      before do
        put '/lists/999', params: list_params, headers: @header
      end

      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a not found message' do
        expect(response_body['payload']).to eq(LIST_NOT_FOUND)
      end
    end

    context 'with an invalid payload' do
      before do
        @list_id = @user.lists.first.id
        put "/lists/#{@list_id}", params: {list_name: 'wrong param name'}, headers: @header
      end

      it_behaves_like 'an invalid request'

      it 'returns a :conflict status' do
        expect(response).to have_http_status(:bad_request)
      end

      it "returns a payload with #{INVALID_PARAMETER}" do
        expect(response_body['payload']).to eq(INVALID_PARAMETER)
      end
    end

    context 'with a valid payload' do
      before do
        @list_id = @user.lists.first.id
        put "/lists/#{@list_id}", params: list_params, headers: @header
      end

      it 'returns a :no_content http status' do
        expect(response).to have_http_status (:no_content)
      end
    end
  end

  describe "DELETE /lists/:list_id" do
    before do
      @user = create(:user)
      2.times { |i| user.all_lists.create(name: "List #{i}", user: @user)}
      token = JsonWebToken.encode(id: @user.id)
      @header = { AUTHORIZATION: "token #{token}"}
    end

    context 'with an invalid id' do
      before do
        delete '/lists/999', headers: @header
      end

      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a List not found payload' do
        expect(response_body['payload']).to eq(LIST_NOT_FOUND)
      end
    end

    context 'with a valid id' do
      before do
        @list_id = @user.lists.first.id
        delete "/lists/#{@list_id}", headers: @header
      end

      it 'returns a :no_content http status' do
        expect(response).to have_http_status (:no_content)
      end

      it 'deletes the list' do
        get '/lists', headers: @header
        actual = response_body['payload'].all? { |i| i['id'] != @list_id }
        expect(actual).to eq(true)
      end
    end
  end
end
