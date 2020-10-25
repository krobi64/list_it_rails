# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthorizeApiRequest do

  context 'with a valid JWT token' do
    before do
      @user = create :user
      @token = JsonWebToken.encode(id: @user.id)
      @header = { 'AUTHORIZATION' => "Bearer Token: #{@token}"}
      @response = AuthorizeApiRequest.new(@header).call
    end

    it 'successfully return the user' do
      expect(@response).to be_successful
      expect(@response.result).to eq(@user)
    end
  end

  context 'without a JWT token' do
    before do
      @user = create :user
      @header = { accept: 'application/json' }
      @response = AuthorizeApiRequest.new(@header).call
    end

    it 'fails with an error' do
      expect(@response).to be_failure
      expect(@response.errors[:token]).to include('Missing token')
    end
  end

  context 'with an invalid token' do
    before do
      @user = create :user
      @header = { 'AUTHORIZATION' => 'Bearer Token: 12345'}
      @response = AuthorizeApiRequest.new(@header).call
    end

    it 'fails with an error' do
      expect(@response).to be_failure
      expect(@response.errors[:token]).to include('Invalid token')
    end
  end
end
