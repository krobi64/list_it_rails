# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Accounts", type: :request do
  let(:email) { 'joe@example.test' }
  let(:password) { 'ThisIs1VeryValidPassword!' }

  let(:params) {
    {
      email: email,
      password: password,
      password_confirmation: password
    }
  }

  describe 'POST /accounts' do
    context 'with valid parameters' do
      it 'returns a 201 status' do
        post '/accounts', params: { user: params }
        expect(response).to have_http_status(:created)
      end

      it 'returns the a JSON package with a success status' do
        post '/accounts', params: { user: params }
        body = JSON.parse(response.body)
        expect(body['status']).to eq('success')
      end

      it 'returns a JWT for the user in the payload' do
        post '/accounts', params: { user: params }
        body = JSON.parse(response.body)
        token = body['payload']
        user = User.find_by(email: email)
        expect(JsonWebToken.decode(token)['id']).to eq(user.id)
      end
    end

    context 'with a full set of parameters' do
      let(:params) {
        {
            email: email,
            password: password,
            password_confirmation: password,
            first_name: 'Joe',
            last_name: 'Test'
        }
      }

      it 'returns a 201 status' do
        post '/accounts', params: { user: params }
        expect(response).to have_http_status(:created)
      end

      it 'returns the a JSON package with a success status' do
        post '/accounts', params: { user: params }
        body = JSON.parse(response.body)
        expect(body['status']).to eq('success')
      end

      it 'returns a JWT for the user in the payload' do
        post '/accounts', params: { user: params }
        body = JSON.parse(response.body)
        token = body['payload']
        user = User.find_by(email: email)
        expect(JsonWebToken.decode(token)['id']).to eq(user.id)
      end
    end

    context 'with an invalid email' do
      let(:email) { 'Joe@abc' }
      it 'returns a bad_request status' do
        post '/accounts', params: { user: params }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a JSON package with an error status' do
        post '/accounts', params: { user: params }
        body = JSON.parse(response.body)
        expect(body['status']).to eq('error')
      end

      it 'returns an email error in the payload' do
        post '/accounts', params: { user: params }
        body = JSON.parse(response.body)
        expect(body['payload']['email']).to_not be_empty
      end
    end

    context 'with an invalid password' do
      let(:password) { 'password' }

      it 'returns a 422 status' do
        post '/accounts', params: { user: params }
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a JSON package with an error status' do
        post '/accounts', params: { user: params }
        body = JSON.parse(response.body)
        expect(body['status']).to eq('error')
      end

      it 'returns an password error in the payload' do
        post '/accounts', params: { user: params }
        body = JSON.parse(response.body)
        expect(body['payload']['password']).to_not be_empty
      end
    end
  end
end
