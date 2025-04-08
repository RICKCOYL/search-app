require 'rails_helper'

RSpec.describe Api::V1::SearchesController, type: :controller do
  describe "POST #record" do
    it "creates a new search query" do
      expect {
        post :record, params: { query: "test query" }
      }.to change(SearchQuery, :count).by(1)
      
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["status"]).to eq("success")
    end
    
    it "does not create a search query for empty query" do
      expect {
        post :record, params: { query: "" }
      }.not_to change(SearchQuery, :count)
      
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["status"]).to eq("error")
    end
  end
  
  describe "GET #search" do
    before do
      @article1 = Article.create(title: "Ruby Programming", content: "Ruby is great")
      @article2 = Article.create(title: "Python Programming", content: "Python is easy")
    end
    
    it "returns matching articles as JSON" do
      get :search, params: { query: "Ruby" }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response[0]["title"]).to eq("Ruby Programming")
    end
    
    it "returns empty array for no matches" do
      get :search, params: { query: "JavaScript" }
      
      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response).to be_empty
    end
  end
end
