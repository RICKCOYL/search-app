require 'rails_helper'

RSpec.describe SearchQuery, type: :model do
  let(:ip_address) { '127.0.0.1' }

  describe 'validations' do
    it 'is valid with query and ip_address' do
      search_query = SearchQuery.new(query: 'test', ip_address: ip_address)
      expect(search_query).to be_valid
    end

    it 'is invalid without query' do
      search_query = SearchQuery.new(ip_address: ip_address)
      expect(search_query).not_to be_valid
    end

    it 'is invalid without ip_address' do
      search_query = SearchQuery.new(query: 'test')
      expect(search_query).not_to be_valid
    end
  end

  describe '.track_search' do
    let(:query) { 'test query' }

    it 'creates a new search query' do
      expect {
        described_class.track_search(query, ip_address)
      }.to change(SearchQuery, :count).by(1)
    end

    it 'increments search count for existing queries' do
      described_class.track_search(query, ip_address)
      search_query = described_class.track_search(query, ip_address)
      expect(search_query.search_count).to eq(2)
    end
  end

  describe '.top_searches' do
    before do
      SearchQuery.create!(query: 'query 1', ip_address: '127.0.0.1', completed: true, search_count: 1)
      SearchQuery.create!(query: 'query 1', ip_address: '127.0.0.2', completed: true, search_count: 1)
      SearchQuery.create!(query: 'query 2', ip_address: '127.0.0.1', completed: true, search_count: 1)
    end

    it 'returns completed searches ordered by count' do
      top_searches = described_class.top_searches
      expect(top_searches).to be_a(Hash)
      expect(top_searches.values.first).to eq(2)
    end

    it 'limits results to specified number' do
      top_searches = described_class.top_searches(1)
      expect(top_searches.size).to eq(1)
    end
  end

  describe '.searches_by_ip' do
    let(:ip_address) { '127.0.0.1' }

    before do
      SearchQuery.create!(query: 'query 1', ip_address: ip_address, completed: true, search_count: 1)
      SearchQuery.create!(query: 'query 1', ip_address: ip_address, completed: true, search_count: 1)
      SearchQuery.create!(query: 'query 2', ip_address: ip_address, completed: true, search_count: 1)
    end

    it 'returns search counts' do
      searches = described_class.searches_by_ip(ip_address)
      expect(searches).to be_a(Hash)
      expect(searches['query 1']).to eq(2)
    end

    it 'only returns completed searches' do
      SearchQuery.create!(query: 'incomplete', ip_address: ip_address, completed: false, search_count: 1)
      searches = described_class.searches_by_ip(ip_address)
      expect(searches['incomplete']).to be_nil
    end
  end

  describe ".find_and_mark_completed" do
    let(:ip_address) { "127.0.0.1" }
    
    it "creates a new completed search query" do
      expect {
        SearchQuery.find_and_mark_completed("ruby", ip_address)
      }.to change(SearchQuery, :count).by(1)
      
      last_query = SearchQuery.last
      expect(last_query.query).to eq("ruby")
      expect(last_query.completed).to be_truthy
    end
  end

  describe '.analytics_for_ip' do
    let(:ip_address) { '127.0.0.1' }

    before do
      SearchQuery.create!(query: 'query 1', ip_address: ip_address, completed: true, search_count: 1)
      SearchQuery.create!(query: 'query 2', ip_address: ip_address, completed: true, search_count: 1)
    end

    it 'returns completed searches for the IP' do
      analytics = described_class.analytics_for_ip(ip_address)
      expect(analytics.size).to eq(2)
      expect(analytics.first.completed).to be true
    end

    it 'orders by search count' do
      SearchQuery.create!(query: 'query 3', ip_address: ip_address, completed: true, search_count: 2)
      analytics = described_class.analytics_for_ip(ip_address)
      expect(analytics.first.query).to eq('query 3')
    end
  end
end
