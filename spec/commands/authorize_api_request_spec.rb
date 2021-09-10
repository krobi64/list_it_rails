# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizeApiRequest do

  context 'with a valid JWT token' do
    before do
    end

    it 'successfully returns the user' do
      user = create :user
      token = JsonWebToken.encode(id: user.id)
      header = { 'AUTHORIZATION' => "Bearer Token: #{token}"}
      response = AuthorizeApiRequest.new(header).call
      expect(response).to be_successful
      expect(response.result).to eq(user)
    end
  end

  context 'without a JWT token' do
    it 'fails with an error' do
      header = { accept: 'application/json' }
      response = AuthorizeApiRequest.new(header).call
      expect(response).to be_failure
      expect(response.errors[:token]).to include(MISSING_TOKEN)
    end
  end

  context 'with an invalid token' do
    it 'fails with an error' do
      header = { 'AUTHORIZATION' => 'Bearer Token: 12345'}
      response = AuthorizeApiRequest.new(header).call
      expect(response).to be_failure
      expect(response.errors[:token]).to include(INVALID_TOKEN)
    end
  end
end
