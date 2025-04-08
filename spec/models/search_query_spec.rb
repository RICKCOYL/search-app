require 'rails_helper'

RSpec.describe SearchQuery, type: :model do
  describe "validations" do
    it "is valid with query and ip_address" do
      search_query = SearchQuery.new(query: "test query", ip_address: "127.0.0.1")
      expect(search_query).to be_valid
    end
    
    it "is invalid without query" do
      search_query = SearchQuery.new(ip_address: "127.0.0.1")
      expect(search_query).not_to be_valid
    end
    
    it "is invalid without ip_address" do
      search_query = SearchQuery.new(query: "test query")
      expect(search_query).not_to be_valid
    end
  end
  
  describe ".top_searches" do
    before do
      3.times { SearchQuery.create(query: "ruby", ip_address: "127.0.0.1", completed: true) }
      2.times { SearchQuery.create(query: "python", ip_address: "127.0.0.1", completed: true) }
      1.times { SearchQuery.create(query: "javascript", ip_address: "127.0.0.1", completed: true) }
      SearchQuery.create(query: "go", ip_address: "127.0.0.1", completed: false)
    end
    
    it "returns top searches in order" do
      top_searches = SearchQuery.top_searches
      expect(top_searches.keys[0]).to eq("ruby")
      expect(top_searches.keys[1]).to eq("python")
      expect(top_searches.keys[2]).to eq("javascript")
    end
    
    it "only includes completed searches" do
      top_searches = SearchQuery.top_searches
      expect(top_searches.keys.include?("go")).to be_falsey
    end
    
    it "limits results to specified number" do
      top_searches = SearchQuery.top_searches(2)
      expect(top_searches.size).to eq(2)
    end
  end
  
  describe ".searches_by_ip" do
    before do
      2.times { SearchQuery.create(query: "ruby", ip_address: "127.0.0.1", completed: true) }
      1.times { SearchQuery.create(query: "python", ip_address: "127.0.0.1", completed: true) }
      3.times { SearchQuery.create(query: "javascript", ip_address: "192.168.1.1", completed: true) }
    end
    
    it "returns searches for specific IP" do
      ip1_searches = SearchQuery.searches_by_ip("127.0.0.1")
      expect(ip1_searches.keys.sort).to eq(["python", "ruby"])
      expect(ip1_searches["ruby"]).to eq(2)
      expect(ip1_searches["python"]).to eq(1)
    end
    
    it "does not include searches from other IPs" do
      ip1_searches = SearchQuery.searches_by_ip("127.0.0.1")
      expect(ip1_searches.keys.include?("javascript")).to be_falsey
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
end
