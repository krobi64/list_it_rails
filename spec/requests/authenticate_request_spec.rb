# frozen_string_literal: true

require 'rails_helper'
require 'json_web_token'

RSpec.describe 'Authenticate', type: :request do
  describe "POST /authenticate" do
    subject { JSON.parse response.body }

    context 'with proper credentials' do
      before do
        user = create :user
        post authenticate_path, params: {email: user.email, password: 'This_Is_A_Basic_P4ssword'}
      end

      it 'responds with 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a valid jwt' do
        expect(subject).to be_a(Hash)
        expect(subject['status']).to eq('success')
        decoded_token = JsonWebToken.decode(subject['payload'])
        user = User.first
        expect(decoded_token['id']).to eq(user.id)
        expect(decoded_token).to have_key('exp')
        expect(decoded_token['exp']).to be_an(Integer)
        expect(decoded_token['exp'] > 1589396000).to be(true)
      end
    end

    context 'with no credentials' do
      before do
        post authenticate_path
      end

      it 'responds with :unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error packet' do
        expect(subject['status']).to eq('error')
        expect(subject['payload']).to have_key('user_authentication')
        expect(subject['payload']['user_authentication']).to eq(INVALID_CREDENTIALS)
      end
    end

    context 'with invalid credentials' do
      before do
        create :user
        post authenticate_path, params: {email: 'example@mail.com', password: 'invalid password'}
      end

      it 'responds with a 401' do
        expect(response).to have_http_status(:unauthorized)
        expect(subject['status']).to eq('error')
        expect(subject['payload']).to have_key('user_authentication')
        expect(subject['payload']['user_authentication']).to eq(INVALID_CREDENTIALS)
      end

    end
  end
end
