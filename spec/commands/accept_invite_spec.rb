# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AcceptInvite do
  subject { described_class.new(recipient, invite_token) }

  let(:sender) { create :user }
  let(:recipient) { create :user }
  let(:sender_list) { sender.lists.create(name: 'Sample List') }
  let(:invite_token) { Invite.create(sender: sender, email: recipient.email, list: sender_list).token }

  let(:accept_invite_command) { subject.call }

  context 'with valid parameters' do
    it 'is successful' do
      expect(accept_invite_command).to be_successful
    end

    it 'enables the recipient to access the list' do
      accept_invite_command
      actual = recipient.all_lists.first
      expect(actual).to eq(sender_list)
    end
  end

  context 'with an invalid token' do
    let(:invite_token) { 'somethinginvalid' }

    it 'fails' do
      expect(accept_invite_command).to be_failure
    end

    it 'returns an error message' do
      actual = accept_invite_command.errors[:token]
      expect(actual).to eq([INVALID_INVITATION_TOKEN])
    end
  end

  context 'with an incorrect recipient' do
    let(:wrong_user) { create :user }
    let (:accept_invite_command) { described_class.new(wrong_user, invite_token).call }

    it 'fails' do
      expect(accept_invite_command).to be_failure
    end

    it 'returns an error message' do
      actual = accept_invite_command.errors[:token]
      expect(actual).to eq([INVALID_INVITATION_TOKEN])
    end
  end

end
