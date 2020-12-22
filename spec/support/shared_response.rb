RSpec.shared_examples 'a successful request without a body' do
  it 'is successful' do
    expect(response.status).to be_between(200,204)
  end
end

RSpec.shared_examples 'a successful request' do
  let(:respone_body) { JSON.parse response.body }

  it_behaves_like 'a successful request without a body'

  it 'returns with a body with :status and :payload' do
    expect(response_body).to have_key('status')
    expect(response_body).to have_key('payload')
  end

  it 'returns a successful status' do
    expect(response_body['status']).to eq('success')
  end
end

RSpec.shared_examples 'an invalid request' do
  let(:respone_body) { JSON.parse response.body }

  it 'returns an http error status' do
    expect(response.status).to be_between(400,422)
  end

  it 'returns a body with :status and :payload' do
    expect(response_body).to have_key('status')
    expect(response_body).to have_key('payload')
  end

  it 'returns an error status' do
    expect(response_body['status']).to eq('error')
  end

  it 'includes an error body' do
    expect(response_body['payload']).to_not be_empty
  end
end

RSpec.shared_examples 'a request that fails without a valid JWT' do
  let(:response_body) { JSON.parse response.body }

  context 'without a JWT' do
    it 'returns a 401' do
      expect(response.status).to eq(401)
      # expect(response_body['status']).to eq('error')
      # expect(response_body['payload']['token']).to eq('Missing token')
    end
  end

  context 'with an Invalid JWT' do
    it 'returns a 401' do
      expect(response.status).to eq(401)
      # expect(response_body['status']).to eq('error')
      # expect(response_body['payload']['token']).to eq('Invalid token')
    end
  end
end
