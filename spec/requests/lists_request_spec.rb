require 'rails_helper'
require_relative '../support/shared_response'

LIST_NOT_FOUND = I18n.t('activerecord.models.list.errors.not_found')
USER_NOT_FOUND = I18n.t('activerecord.models.user.errors.not_found')
INVALID_PARAMETER = I18n.t('actioncontroller.errors.list.invalid_parameters')

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
      it 'returns a success status' do
        expect(response).to have_http_status(:created)
      end
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

  describe 'GET /lists/:id' do
    before do
      @user = create(:user_with_lists)
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
      @user = create(:user_with_lists)
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
        expect(response).to have_http_status(:conflict)
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
      @user = create(:user_with_lists)
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

  describe "POST /share" do
    context 'with an existing user' do
      before do
        @owner = create(:user_with_lists)
        @list = @owner.lists.first
        @user = create(:user)
        token = JsonWebToken.encode(id: @owner.id)
        @header = { AUTHORIZATION: "token #{token}" }
        post "/lists/#{@list.id}/share", params: {email: @user.email}, headers: @header
      end

      it 'returns a :no_content http status' do
        expect(response).to have_http_status (:no_content)
      end

      it 'adds the list to the second user' do
        token = JsonWebToken.encode(id: @user.id)
        header = { AUTHORIZATION: "token #{token}" }
        get '/lists', headers: header
        actual = response_body['payload'].any? { |list| list['id'] == @list.id }
        expect(actual).to eq(true)
      end
    end

    context 'without an existing user account' do
      before do
        @new_email = 'non_existing@example.com'
        @owner = create(:user_with_lists)
        @list = @owner.lists.first
        token = JsonWebToken.encode(id: @owner.id)
        @header = { AUTHORIZATION: "token #{token}" }
        post "/lists/#{@list.id}/share", params: {email: @new_email}, headers: @header
      end

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
