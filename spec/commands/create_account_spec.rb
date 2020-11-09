# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateAccount do
  subject { described_class.new(email, password, password_confirmation) }

  let(:email) { 'joe@example.test' }
  let(:password) { 'ThisIs1VeryValidPassword!' }
  let(:password_confirmation) { password }

  let(:create_account_command) { subject.call }

  context 'with valid parameters' do
    it 'successfully creates the account and returns a JWT for the new user' do
      expect(create_account_command).to be_successful
      expect(User.exists?(email: email)).to be(true)
      user = User.find_by(email: email)
      expect(JsonWebToken.decode(create_account_command.result)['id']).to eq(user.id)
    end
  end

  context 'with an invalid email' do
    let(:email) { 'joe@abc' }

    it 'fails with an error' do
      expect(create_account_command).to be_failure
      expect(create_account_command.errors.messages[:email]).to_not be_empty
    end
  end

  context 'with a password that is too short' do
    let (:password) { 'Th!s5h' }

    it 'fails with an error' do
      expect(create_account_command).to be_failure
      expect(create_account_command.errors.messages[:password]).to_not be_empty
    end
  end

  context 'with a password that does not contain a number' do
    let (:password) { 'ThisDoes<Not>ContainANumber' }

    it 'fails with an error' do
      expect(create_account_command).to be_failure
      expect(create_account_command.errors.messages[:password]).to_not be_empty
    end
  end

  context 'with a password that does not contain a symbol' do
    let (:password) { 'ThisDoesN0tContainASymbol' }

    it 'fails with an error' do
      expect(create_account_command).to be_failure
      expect(create_account_command.errors.messages[:password]).to_not be_empty
    end
  end

  context 'with a password that does not contain a lowercase letter' do
    let (:password) { 'THIS1S&YELLING' }

    it 'fails with an error' do
      expect(create_account_command).to be_failure
      expect(create_account_command.errors.messages[:password]).to_not be_empty
    end
  end

  context 'with a password that does not contain an uppercase letter' do
    let (:password) { 'thisis1verypassword!' }

    it 'fails with an error' do
      expect(create_account_command).to be_failure
      expect(create_account_command.errors.messages[:password]).to_not be_empty
    end
  end

  context 'without a confirmation password' do
    let(:password_confirmation) { '' }

    it 'fails with an error' do
      expect(create_account_command).to be_failure
      expect(create_account_command.errors.messages[:password_confirmation]).to_not be_empty
    end
  end
end
