require 'rails_helper'

RSpec.describe SearchController, type: :controller do
  describe 'GET #index' do
    let(:ip_address) { '127.0.0.1' }

    before do
      # Create test data for the same IP address
      SearchQuery.create!(query: 'test query 1', ip_address: ip_address, completed: true, search_count: 3)
      SearchQuery.create!(query: 'test query 2', ip_address: ip_address, completed: true, search_count: 2)
      # Create data for a different IP to ensure we're filtering correctly
      SearchQuery.create!(query: 'test query 3', ip_address: '127.0.0.2', completed: true, search_count: 1)
    end
  end

  describe 'GET #search' do
    let(:ip_address) { '127.0.0.1' }
    let(:query) { 'test query' }

    before do
      allow(request).to receive(:remote_ip).and_return(ip_address)
    end

    it 'tracks the search query' do
      expect {
        get :search, params: { query: query }
      }.to change(SearchQuery, :count).by(1)
    end

    it 'marks long queries as completed' do
      get :search, params: { query: 'long query' }
      expect(SearchQuery.last.completed).to be true
    end

    it 'does not mark short queries as completed' do
      get :search, params: { query: 'a' }
      expect(SearchQuery.last.completed).to be false
    end

    it 'returns search data in JSON format' do
      get :search, params: { query: query }
      expect(response).to be_successful
      json = JSON.parse(response.body)
      expect(json['status']).to eq('success')
      expect(json['top_searches']).to be_a(Hash)
      expect(json['user_searches']).to be_a(Array)
    end
  end
end 