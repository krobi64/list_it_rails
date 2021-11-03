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
  let(:lists) { 2.times { |i| current_user.all_lists.create(name: "List #{i}", user: current_user)}}
  let(:list) { lists && current_user.lists.first }
  let(:list_item) { list.items.create(name: 'List Item') }
  let(:recipient_lists) { 2.times { |i| recipient.all_lists.create(name: "List #{i}", user: recipient)} }
  let(:recipient_list) { recipient_lists && recipient.lists.first }
  let(:recipient_item) { recipient_list.items.create(name: 'Invalid Item') }
  let(:list_id) { list.id }
  let(:response_body) { JSON.parse response.body }
  let(:payload) { response_body['payload'] }

  before do
    2.times { |i| current_user.all_lists.create(name: "List #{i}", user: current_user)}
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

    context 'without a JWT' do
      let(:header) { {} }

      it_behaves_like 'a request that fails without a valid JWT'
    end

    context 'with valid parameters' do
      it_behaves_like 'a successful request'
      it 'returns a created status' do
        expect(response).to have_http_status(:created)
      end

      it 'returns the item' do
        expected = list.items.first.attributes.except('created_at', 'updated_at', 'list_id')
        expect(payload).to eq(expected)
      end

      it 'adds the item to the list' do
        expect(list.items.first.name).to eq(body[:item][:name])
      end

      it 'sets the item status to unchecked' do
        expect(list.items.first.state).to eq(Item::ITEM_STATE[:unchecked])
      end

      it 'sets the correct order on the item' do
        expect(list.items.first.order).to eq(0)
      end

      context 'when created by a shared user' do
        let(:token) { JsonWebToken.encode(id: recipient.id) }

        before do
          recipient.all_lists << list
          post "/lists/#{list_id}/items", params: body, headers: header
        end
        it_behaves_like 'a successful request'

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
      it_behaves_like 'a request with an invalid list'
    end
  end

  describe 'GET /lists/:list_id/items' do
    before do
      3.times { |i| list.items.create(name: "Item #{i}") }
      get "/lists/#{list_id}/items", headers: header
    end

    context 'without a JWT' do
      let(:header) { {} }

      it_behaves_like 'a request that fails without a valid JWT'
    end

    context 'getting all items' do
      it_behaves_like 'a successful request'

      it 'returns an :ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the all of the items' do
        expect(payload.size).to eq(3)
      end

      it 'returns the items in order' do
        actual = payload.map { |i| i['order'] }
        expect(actual).to eq([0, 1, 2])
      end
    end

    context 'requesting unchecked items only ' do
      before do
        list.items.second.toggle_state
        get "/lists/#{list_id}/items?uc=1", headers: header
      end

      it 'only returns the unchecked items' do
        actual = payload.all? { |i| i['state'] == Item::ITEM_STATE[:unchecked] }
        expect(actual).to eq(true)
      end

      it 'returns the items in order' do
        actual = payload.map {|i| i['order']}
        expect(actual).to eq([0,2])
      end
    end

    context 'requesting items from an unauthorized list' do

      let(:list_id) { recipient_list.id }

      it_behaves_like 'a request with an invalid list'
    end
  end

  describe 'GET /lists/:list_id/items/:id' do
    before do
      get "/lists/#{list.id}/items/#{list_item.id}", headers: header
    end

    let(:item_hash) {
      {
        "id" => list_item.id,
        "name" => list_item.name,
        "order" => list_item.order,
        "state" => list_item.state,
        "token" => list_item.token
      }
    }

    context 'without a JWT' do
      let(:header) { {} }

      it_behaves_like 'a request that fails without a valid JWT'
    end

    context 'correct retrieval' do
      it_behaves_like 'a successful request'

      it 'returns an :ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the item' do
        expect(payload).to eq(item_hash)
      end
    end

    context 'with an invalid list' do
      let(:list_id) { recipient_list.id }
      let(:item_id) { recipient_item.id }

      before do
        get "/lists/#{list_id}/items/#{item_id}", headers: header
      end

      it_behaves_like 'a request with an invalid list'
    end

    context 'with an invalid item id' do
      let(:list_item) { recipient_item }

      it_behaves_like 'a request with an invalid list item'
    end
  end

  describe 'PUT /lists/:list_id/items/:id' do
    let(:item) { list.items.first }
    let(:item_id) { item.id }
    let(:body) {
      {
        item: {
          name: 'New name'
        }
      }
    }

    before do
      3.times { |i| list.items.create(name: "Item #{i}") }
      put "/lists/#{list_id}/items/#{item_id}", params: body, headers: header
    end

    context 'without a JWT' do
      let(:header) { {} }

      it_behaves_like 'a request that fails without a valid JWT'
    end

    context 'with a correct request' do
      it_behaves_like 'a successful request without a body'

      it 'returns a :no_content status' do
        expect(response).to have_http_status(:no_content)
      end

      it 'updates the name' do
        expect(list.items.first.name).to eq('New name')
      end
    end

    context 'with an invalid payload' do
      let(:body) { { name: 'A different name' } }

      it_behaves_like 'an invalid request'

      it 'returns a :bad_request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it "returns a payload with #{INVALID_PARAMETER}" do
        expect(payload).to eq(INVALID_PARAMETER)
      end
    end

    context 'with an empty payload' do
      let(:body) { {} }

      it_behaves_like 'an invalid request'

      it 'returns a :bad_request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it "returns a payload with #{INVALID_PARAMETER}" do
        expect(payload).to eq(INVALID_PARAMETER)
      end
    end

    context 'with an invalid list' do
      before do
        put "/lists/49/items/#{item_id}", params: body, headers: header
      end

      it_behaves_like 'a request with an invalid list'
    end

    context 'with an invalid item' do
      let(:item_id) { recipient_item.id }
      before do
        put "/lists/#{list_id}/items/#{item_id}", params: body, headers: header
      end

      it_behaves_like 'a request with an invalid list item'
    end
  end

  describe 'PUT /lists/:list_id/items/reorder' do
    let(:item) { list.items.first }
    let(:item_id) { item.id }
    let(:body) {
      {
        order: [
          list.items.third.token,
          list.items.first.token,
          list.items.second.token
        ]
      }
    }

    before do
      3.times { |i| list.items.create(name: "Item #{i}") }
      put "/lists/#{list_id}/items/reorder", params: body, headers: header
    end

    context 'without a JWT' do
      let(:header) { {} }

      it_behaves_like 'a request that fails without a valid JWT'
    end

    context 'with a correct request' do
      it_behaves_like 'a successful request'

      it 'returns an :ok status' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the list of items in their new order' do
        actual = payload.map { |item| item['name'] }
        expect(["Item 2", "Item 0", "Item 1"]).to eq(actual)
      end
    end

    context 'with an invalid payload' do
      let(:body) {
        {
          order: [
            list.items.third.token,
            list.items.second.token
          ]
        }
      }

      it_behaves_like 'an invalid request'

      it 'returns a :bad_request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it "returns a message of #{INVALID_ITEMS}" do
        expect(payload).to eq(INVALID_ITEMS)
      end
    end

    context 'with an invalid list' do
      let(:list_id) { 49 }

      it_behaves_like 'a request with an invalid list'
    end

    context 'with an invalid item id' do
      let(:body) {
        {
          order: [
            list.items.third.token,
            list.items.second.token,
            recipient_item.token
          ]
        }
      }

      it_behaves_like 'an invalid request'

      it 'returns a :not_found status' do
        expect(response).to have_http_status(:not_found)
      end

      it "returns the message #{ITEM_NOT_FOUND}" do
        expect(payload).to eq(ITEM_NOT_FOUND)
      end
    end
  end

  describe 'PUT /lists/:list_id/items/:item_id/toggle' do
    before do
      3.times { |i| list.items.create(name: "Item #{i}") }
      list.items.second.toggle_state
    end

    context 'without a JWT' do
      let(:header) { {} }
      let(:item_id) { list_item.id }

      before do
        put "/lists/#{list.id}/items/#{item_id}/toggle", headers: header
      end

      it_behaves_like 'a request that fails without a valid JWT'
    end

    context 'without a state param' do
      let(:item_id) { list_item.id }

      before do
        put "/lists/#{list.id}/items/#{item_id}/toggle", headers: header
      end

      it_behaves_like 'a successful request without a body'

      it 'returns a status of :no_content' do
        expect(response).to have_http_status(:no_content)
      end

      it 'toggles the item state' do
        list_item.reload
        expect(list_item.state).to eq(Item::ITEM_STATE[:checked])
      end

      context 'undoing the check' do
        let(:list_item) { list.items.second }

        it 'toggles back to unchecked' do
          list_item.reload
          expect(list_item.state).to eq(Item::ITEM_STATE[:unchecked])
        end
      end
    end

    context 'with a state parameter' do
      let(:item_id) { list_item.id }

      before do
        put "/lists/#{list.id}/items/#{item_id}/toggle?state=0", headers: header
      end

      it_behaves_like 'a successful request without a body'

      it 'returns a :no_content status' do
        expect(response).to have_http_status(:no_content)
      end

      it 'sets the correct state' do
        list_item.reload
        expect(list_item.state).to eq(Item::ITEM_STATE[:unchecked])
      end

      context 'converse' do
        let(:list_item) { list.items.second }

        it 'sets the correct state' do
          list_item.reload
          expect(list_item.state).to eq(Item::ITEM_STATE[:unchecked])
        end
      end
    end

    context 'with an invalid list' do
      before do
        put '/lists/49/items/1/toggle', headers: header
      end

      it_behaves_like 'a request with an invalid list'
    end

    context 'with an invalid item' do
      before do
        put "/lists/#{list_id}/items/#{recipient_item.id}/toggle", headers: header
      end

      it_behaves_like 'a request with an invalid list item'
    end
  end

  describe 'DELETE /lists/:list_id/items/:item_id' do
    let(:item_id) { list_item.id }

    before do
      delete "/lists/#{list_id}/items/#{item_id}", headers: header
    end

    context 'without a JWT' do
      let(:header) { {} }

      it_behaves_like 'a request that fails without a valid JWT'
    end

    context 'with a valid list item' do
      it_behaves_like 'a successful request without a body'

      it 'returns a :no_content status' do
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes the item' do
        expect(Item.exists?(item_id)).to eq(false)
      end
    end

    context 'with an invalid list' do
      let(:list_id) { 49 }

      it_behaves_like 'a request with an invalid list'
    end

    context 'with an invalid item' do
      let(:item_id) { recipient_item.id }

      it_behaves_like 'a request with an invalid list item'
    end
  end
end
