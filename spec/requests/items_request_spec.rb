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
  let(:payload) { response_body['payload'] }

  before do
    2.times { |i| current_user.all_lists.create(name: "List #{i}", user: current_user)}
  end

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

      it 'sets the item status to unchecked' do
        expect(list.items.first.state).to eq(Item::ITEM_STATE[:unchecked])
      end

      it 'sets the correct order on the item' do
        expect(list.items.first.order).to eq(1)
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
        expect(payload['name']).to eq([ITEM_NAME_BLANK])
      end
    end

    context 'with an invalid list' do
      let(:list_id) { 49 }
      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns the appropriate error message' do
        expect(payload).to eq(LIST_NOT_FOUND)
      end
    end
  end

  describe 'GET /lists/:list_id/items' do
    before do
      3.times { |i| list.items.create(name: "Item #{i}") }
      list.items.second.toggle_state
    end

    context 'getting all items' do
      before do
        get "/lists/#{list_id}/items", headers: header
      end

      it_behaves_like 'a successful request'

      it 'returns an :ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the all of the items' do
        expect(payload.size).to eq(3)
      end

      it 'returns the items in order' do
        actual = payload.map { |i| i['order'] }
        expect(actual).to eq([1, 2, 3])
      end
    end

    context 'requesting unchecked items only ' do
      before do
        get "/lists/#{list_id}/items?uc=1", headers: header
      end

      it 'only returns the unchecked items' do
        actual = payload.all? { |i| i['state'] == Item::ITEM_STATE[:unchecked] }
        expect(actual).to eq(true)
      end

      it 'returns the items in order' do
        actual = payload.map {|i| i['order']}
        expect(actual).to eq([1,3])
      end
    end

    context 'requesting items from an unauthorized list' do

      let(:list_id) { recipient.lists.first.id }

      before do
        2.times { |i| recipient.all_lists.create(name: "List #{i}", user: recipient)}
        get "/lists/#{list_id}/items", headers: header
      end

      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it "returns a message #{LIST_NOT_FOUND}" do
        expect(payload).to eq(LIST_NOT_FOUND)
      end
    end
  end

  describe 'GET /lists/:list_id/items/:id' do
    before do
      3.times { |i| list.items.create(name: "Item #{i}") }
      list.items.second.toggle_state
    end

    let(:item) { list.items.first }
    let(:item_hash) {
      {
        "id" => item.id,
        "name" => item.name,
        "order" => item.order,
        "state" => item.state
      }
    }

    context 'correct retrieval' do
      before do
        get "/lists/#{list_id}/items/#{item.id}", headers: header
      end

      it_behaves_like 'a successful request'

      it 'returns an :ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the item' do
        expect(payload).to eq(item_hash)
      end
    end

    context 'with an invalid list' do
      let(:list_id) { recipient.lists.first.id }
      let(:item_id) { recipient.lists.first.items.first.id }

      before do
        2.times { |i| recipient.all_lists.create(name: "List #{i}", user: recipient)}
        recipient.lists.first.items.create(name: 'Invalid Item')
        get "/lists/#{list_id}/items/#{item_id}", headers: header
      end

      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the message #{LIST_NOT_FOUND}" do
        expect(payload).to eq(LIST_NOT_FOUND)
      end
    end

    context 'with an invalid item id' do
      let(:item_id) { recipient.lists.first.items.first.id }

      before do
        2.times { |i| recipient.all_lists.create(name: "List #{i}", user: recipient)}
        recipient.lists.first.items.create(name: 'Invalid Item')
        get "/lists/#{list_id}/items/#{item_id}", headers: header
      end

      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the message #{ITEM_NOT_FOUND}" do
        expect(payload).to eq(ITEM_NOT_FOUND)
      end
    end
  end
end
