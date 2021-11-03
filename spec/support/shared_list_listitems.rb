RSpec.shared_examples 'a request with an invalid list' do
  it_behaves_like 'an invalid request'

  it 'returns a :not_found status' do
    expect(response).to have_http_status(:not_found)
  end

  it 'returns the appropriate error message' do
    expect(payload).to eq(LIST_NOT_FOUND)
  end
end

RSpec.shared_examples 'a request with an invalid list item' do
  it_behaves_like 'an invalid request'

  it 'returns a :not_found status' do
    expect(response).to have_http_status(:not_found)
  end

  it "returns the message #{ITEM_NOT_FOUND}" do
    expect(payload).to eq(ITEM_NOT_FOUND)
  end
end
