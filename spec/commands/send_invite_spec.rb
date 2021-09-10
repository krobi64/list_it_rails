# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendInvite do
  subject { described_class.new(email, list, sender, recipient) }

  let(:email) { 'joe@example.test' }
  let(:sender) { create :user }
  let(:list) { sender.lists.first }
  let(:recipient) { nil }

  let(:send_invite_command) { subject.call }

  before do
    2.times { |i| sender.all_lists.create(name: "List #{i}", user: sender) }
  end

  context 'with valid parameters and no recipient' do
    it 'is successful' do
      expect(send_invite_command).to be_successful
    end

    it 'creates the Invite' do
      send_invite_command
      expect(Invite.where(sender: sender, list: list).first).to be_an Invite
    end

    it 'returns the Invitation with the token' do
      expect(send_invite_command.result)
    end
  end

  context 'with valid parameters including a recipient' do
    let(:recipient) { create :user }
    let(:email) { recipient.email }

    it 'is successful' do
      expect(send_invite_command).to be_successful
    end

    it 'creates the Invite' do
      send_invite_command
      expect(Invite.where(sender: sender, list: list, recipient: recipient).first).to be_an Invite
    end
  end

  context 'with an invalid email' do
    let(:email) { 'joe@abc' }

    it 'fails' do
      send_invite_command
      expect(send_invite_command).to be_failure
    end

    it 'returns an error' do
      expect(send_invite_command.errors.any? { |e| e.type == INVALID_EMAIL_ADDRESS }).to eq(true)
    end
  end
end
