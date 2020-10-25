require 'rails_helper'
require 'json_web_token'

RSpec.describe 'Authenticate', type: :request do

  describe "POST /authenticate" do
    context 'with proper credentials' do
      subject { JSON.parse response.body }

      before do
        user = create :user
        post authenticate_path, params: {email: user.email, password: 'This_Is_A_Basic_P4ssword'}
      end

      it 'responds with 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a valid jwt' do
        expect(subject).to be_a(Hash)
        expect(subject).to have_key('auth_token')
        decoded_token = JsonWebToken.decode(subject['auth_token'])
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

      it 'responds with 401' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to have_key('user_authentication')
        expect(JSON.parse(response.body)['error']['user_authentication']).to eq('invalid credentials')
      end
    end

    context 'with invalid credentials' do
      before do
        create :user
        post authenticate_path, params: {email: 'example@mail.com', password: 'invalid password'}
      end

      it 'responds with a 401' do
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to have_key('user_authentication')
        expect(JSON.parse(response.body)['error']['user_authentication']).to eq('invalid credentials')
      end

    end
  end
end
