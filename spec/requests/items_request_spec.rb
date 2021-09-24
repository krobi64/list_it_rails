# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Items', type: :request do
  let(:current_user) { create :user }
  let(:recipient) { create :user }
  let(:token) { JsonWebToken.encode(id: current_user.id) }
  let(:header) {
    {
      AUTHORIZATION: "token #{token}"
    }
  }
  let(:list) { current_user.lists.first }
  let(:list_id) { list.id }
  let(:response_body) { JSON.parse response.body }

  context 'without a valid JWT' do
    before do
      get '/lists/38/items'
    end
    it_behaves_like 'a request that fails without a valid JWT'
  end

  describe 'POST /lists/:list_id/items' do
    let(:body) {
      {
        item: {
          name: "Item 1",
        }
      }
    }

    before do
      2.times { |i| current_user.all_lists.create(name: "List #{i}", user: current_user)}
      post "/lists/#{list_id}/items", params: body, headers: header
    end

    context 'with valid parameters' do
      it_behaves_like 'a successful request without a body'
      it 'returns a created status' do
        expect(response).to have_http_status(:created)
      end
      it 'adds the item to the list' do
        expect(list.items.first.name).to eq(body[:item][:name])
      end

      context 'when created by a shared user' do
        let(:token) { JsonWebToken.encode(id: recipient.id) }

        before do
          recipient.all_lists << list
          post "/lists/#{list_id}/items", params: body, headers: header
        end
        it_behaves_like 'a successful request without a body'

        it 'returns the :created status' do
          expect(response).to have_http_status(:created)
        end

        it 'adds the item to the list' do
          expect(list.items.first.name).to eq(body[:item][:name])
        end

        it 'sets the item status to unchecked' do
          expect(list.items.first.state).to eq(Item::ITEM_STATE[:unchecked])
        end
      end
    end

    context 'without a name or a misnamed parameter' do
      let(:body) {
        {
          item: {
            item_name: "Item 1",
          }
        }

      }

      it_behaves_like 'an invalid request'

      it 'returns a :bad_request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns the appropriate error message' do
        expect(response_body['payload']['name']).to eq([ITEM_NAME_BLANK])
      end
    end

    context "with an invalid list" do
      let(:list_id) { 49 }
      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns the appropriate error message' do
        expect(response_body['payload']).to eq(LIST_NOT_FOUND)
      end
    end
  end

end
