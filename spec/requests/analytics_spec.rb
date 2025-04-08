require 'rails_helper'

RSpec.describe Api::V1::AnalyticsController, type: :controller do
  describe "GET #index" do
    before do
      3.times { SearchQuery.create(query: "ruby", ip_address: "127.0.0.1", completed: true) }
      2.times { SearchQuery.create(query: "python", ip_address: "127.0.0.1", completed: true) }
    end
    
    it "returns analytics data as JSON" do
      get :index
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      
      expect(json_response).to have_key("top_searches")
      expect(json_response).to have_key("user_searches")
      expect(json_response["top_searches"]["ruby"]).to eq(3)
      expect(json_response["top_searches"]["python"]).to eq(2)
    end
  end
end
