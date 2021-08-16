require 'rails_helper'
require_relative '../support/shared_response'

LIST_NOT_FOUND = I18n.t('activerecord.models.list.errors.not_found')
INVALID_EMAIL_ADDRESS = I18n.t('activemodel.errors.invalid_email')

RSpec.describe 'Invites', type: :request do
  let(:current_user) { create :user }
  let(:current_user_email) { current_user.email }
  let(:recipient) { create :user }
  let(:recipient_email) { recipient.email }
  let(:token) { JsonWebToken.encode(id: current_user.id) }
  let(:header) {
    {
      AUTHORIZATION: "token #{token}"
    }
  }
  let(:list_id) { current_user.lists.first.id }
  let(:response_body) { JSON.parse response.body }

  context 'without a valid JWT' do
    before do
      get '/invites'
    end
    it_behaves_like 'a request that fails without a valid JWT'
  end

  describe 'POST /invites' do
    let(:body) {
      {
        invite: {
          email: recipient_email,
          list_id: list_id
        }
      }
    }

    before do
      2.times { |i| current_user.all_lists.create(name: "List #{i}", user: current_user)}
      post '/invites', params: body, headers: header
    end

    context 'with an existing user' do
      it_behaves_like 'a successful request without a body'
      it 'returns a created status' do
        expect(response).to have_http_status(:created)
      end

      it 'creates the invite' do
        expect(current_user.sent_invites.first).to be_an(Invite)
        expect(current_user.sent_invites.first.email).to eq(recipient_email)
      end
    end

    context 'with a new user' do
      let(:recipient_email) { 'new_user@example.test' }

      it_behaves_like 'a successful request without a body'
      it 'returns a created status' do
        expect(response).to have_http_status(:created)
      end

      it 'creates the invite' do
        expect(current_user.sent_invites.first).to be_an(Invite)
        expect(current_user.sent_invites.first.email).to eq(recipient_email)
      end
    end

    context 'without a valid list' do
      let(:list_id) { 49 }
      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns a not found message' do
        expect(response_body['payload']).to eq(LIST_NOT_FOUND)
      end
    end

    context 'without a valid email' do
      let(:recipient_email) { 'bogusemail' }
      it_behaves_like 'an invalid request'

      it 'returns a bad request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an Invalid email error message' do
        expect(response_body['payload']['email']).to eq([INVALID_EMAIL_ADDRESS])
      end
    end
  end

  describe 'GET /invites' do
    context 'having both sent and received invites' do
      before do
        2.times { |i| current_user.all_lists.create(name: "List #{i}", user: current_user) }
        2.times { |i| recipient.all_lists.create(name: "List #{i}", user: recipient) }
        SendInvite.new(recipient_email, current_user.lists.first, current_user, recipient).call
        SendInvite.new(current_user_email, recipient.lists.first, recipient, current_user).call
        get '/invites', headers: header
      end

      it_behaves_like 'a successful request'
      it 'returns all invites' do
        expect(response_body['payload'].size).to eq(2)
      end

      it 'returns only invites sent from or sent to the user' do
        actual = response_body['payload'].all? do |invite|
          invite['sender_id'] == current_user.id || invite['recipient_id'] == current_user.id
        end
        expect(actual).to eq(true)
      end
    end

    context 'having no invites' do
      before do
        get '/invites', headers: header
      end

      it_behaves_like 'a successful request'
      it 'returns an empty array in the payload' do
        expect(response_body['payload']).to be_an(Array)
        expect(response_body['payload']).to be_empty
      end
    end
  end
end

