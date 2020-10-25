# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticateUser do
  let(:password) { 'This_Is_A_Basic_P4ssword' }

  before do
    @user = create :user
  end

  context 'with valid parameters' do
    before do
      @response = AuthenticateUser.new(@user.email, password).call
    end

    it 'is successful' do
      expect(@response).to be_successful
    end

    it 'returns a valid JWT for the user' do
      expect(JsonWebToken.decode(@response.result)[:id]).to eq(@user.id)
    end
  end

  context 'with a non-existing email' do
    before do
      @response = AuthenticateUser.new('invalid.email@example.com', password).call
    end

    it 'fails' do
      expect(@response).to be_failure
    end
  end

  context 'with an invalid password' do
    before do
      @response = AuthenticateUser.new(@user.email, 'invalid_password').call
    end

    it 'fails' do
      expect(@response).to be_failure
    end
  end
end
