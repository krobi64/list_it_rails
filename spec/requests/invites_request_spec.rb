# frozen_string_literal: true

require 'rails_helper'

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

      it 'returns an ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns all invites' do
        expect(response_body['payload'].size).to eq(2)
      end

      it 'returns only invites sent from or sent to the user' do
        actual = response_body['payload'].all? do |invite|
          invite['sender'] == current_user.full_name || invite['recipient'] == current_user.full_name
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

  describe 'GET /invite/:invite_id' do
    context 'with the current user as the sender' do
      let (:invite_command) { SendInvite.new(recipient_email, current_user.lists.first, current_user, recipient).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| current_user.all_lists.create(name: "List #{i}", user: current_user)}
        invite_id = invitation.id
        get "/invites/#{invite_id}", headers: header
      end

      it_behaves_like 'a successful request'

      it 'returns an ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the invitation in the payload' do
        expectation = invitation.as_json()
        actual = response_body['payload']

        expect(actual).to eq(expectation)
      end
    end

    context 'with the current user as the recipient' do
      let(:sender) { create :user }
      let (:invite_command) { SendInvite.new(current_user_email, sender.lists.first, sender, current_user).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| sender.all_lists.create(name: "List #{i}", user: sender) }
        invite_id = invitation.id
        get "/invites/#{invite_id}", headers: header
      end

      it_behaves_like 'a successful request'

      it 'returns an ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the invitation in the payload' do
        expectation = invitation.as_json()
        actual = response_body['payload']

        expect(actual).to eq(expectation)
      end
    end

    context 'with an invalid invitation id' do
      let(:sender) { create :user }
      let (:invite_command) { SendInvite.new(recipient_email, sender.lists.first, sender, recipient).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| sender.all_lists.create(name: "List #{i}", user: sender) }
        invite_id = invitation.id
        get "/invites/#{invite_id}", headers: header
      end

      it_behaves_like 'an invalid request'

      it 'returns a not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an Invitation Not Found error message' do
        expect(response_body['payload']).to eq(INVITATION_NOT_FOUND)
      end
    end
  end

  describe 'PUT /invites/:invite_id/resend' do
    context 'with an invite owned by the current user' do
      let (:invite_command) { SendInvite.new(recipient_email, current_user.lists.first, current_user, recipient).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| current_user.all_lists.create(name: "List #{i}", user: current_user) }
        invite_id = invitation.id
        put "/invites/#{invite_id}/resend", headers: header
      end

      it_behaves_like 'a successful request'

      it 'returns an ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns "Invitation sent" in the payload' do
        actual = response_body['payload']

        expect(actual).to eq(INVITATION_SENT)
      end
    end

    context "with an invitation not owned by the current user" do
      let (:invite_command) { SendInvite.new(current_user_email, recipient.lists.first, recipient, current_user).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| recipient.all_lists.create(name: "List #{i}", user: recipient) }
        invite_id = invitation.id
        put "/invite/#{invite_id}/resend", headers: header
      end

      it_behaves_like 'an invalid request'

      it 'returns a not_found status' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PUT /invites/accept?token=:token_value' do
    context 'without a valid JWT' do
      let (:invite_command) { SendInvite.new(current_user_email, recipient.lists.first, recipient, current_user).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| recipient.all_lists.create(name: "List #{i}", user: recipient) }
        @token = invitation.token
        put "/invites/accept?token=#{@token}"
      end

      it 'redirects the user to sign in' do
        expect(response).to redirect_to("#{new_account_path}?token=#{@token}")
      end
    end

    context 'with a valid JWT' do
      let(:target_list) { recipient.lists.first }
      let (:invite_command) { SendInvite.new(current_user_email, target_list, recipient, current_user).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| recipient.all_lists.create(name: "List #{i}", user: recipient) }
        @token = invitation.token
        put "/invites/accept?token=#{@token}", headers: header
      end

      it_behaves_like 'a successful request'

      it 'makes the invited list available to the current_user' do
        actual = current_user.all_lists.any? { |list| list == target_list }
        expect(actual).to eq(true)
      end

      it 'sets the invitation status to Invite::STATUS[:accepted]' do
        invitation.reload
        expect(invitation.status).to eq(Invite::STATUS[:accepted])
      end

      it 'returns the invitation list' do
        expect(response_body['payload']).to eq({ "list" => target_list.as_json })
      end
    end

    context 'with an invalid token' do
      let(:sender) { create :user }
      let(:target_list) { sender.lists.first }
      let (:invite_command) { SendInvite.new(recipient_email, target_list, sender, recipient).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| sender.all_lists.create(name: "List #{i}", user: sender) }
        @token = invitation.token
        put "/invites/accept?token=#{@token}", headers: header
      end

      it_behaves_like 'an invalid request'

      it 'returns a bad_request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an Invalid Token message in the payload' do
        expect(response_body['payload']).to eq({ "token" => INVALID_INVITATION_TOKEN })
      end
    end
  end

  describe 'DEL /invites/:id' do
    context 'with an invite owned by the current user' do
      let (:invite_command) { SendInvite.new(recipient_email, current_user.lists.first, current_user, recipient).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| current_user.all_lists.create(name: "List #{i}", user: current_user) }
        invite_id = invitation.id
        AcceptInvite.new(recipient, invitation.token).call
        delete "/invites/#{invite_id}", headers: header
        recipient.reload
        invitation.reload
      end

      it_behaves_like 'a successful request without a body'

      it 'returns a :no_content status' do
        expect(response).to have_http_status(:no_content)
      end

      it 'sets the invitation status to :disabled' do
        expect(invitation.status).to eq(Invite::STATUS[:disabled])
      end

      it 'denies the invitation recipient access to the list' do
        actual = recipient.all_lists.to_a.any? { |list| list.id == invitation.list.id }
        expect(actual).to eq(false)
      end
    end

    context 'with an invite not owned by the current user' do
      let (:invite_command) { SendInvite.new(current_user_email, recipient.lists.first, recipient, current_user).call }
      let(:invitation) { invite_command.result }

      before do
        2.times { |i| recipient.all_lists.create(name: "List #{i}", user: recipient) }
        invite_id = invitation.id
        AcceptInvite.new(current_user, invitation.token).call
        delete "/invites/#{invite_id}", headers: header
      end

      it_behaves_like 'an invalid request'

      it 'returns a :not_found' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with an invalid list id' do
      before do
        delete '/invite/9aeb', headers: header
      end

      it_behaves_like 'an invalid request'

      it 'returns a :not_found' do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end

