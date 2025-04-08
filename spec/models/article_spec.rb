require 'rails_helper'

RSpec.describe Article, type: :model do
  describe "validations" do
    it "is valid with a title and content" do
      article = Article.new(title: "Test Title", content: "Test content")
      expect(article).to be_valid
    end
    
    it "is invalid without a title" do
      article = Article.new(content: "Test content")
      expect(article).not_to be_valid
    end
  end
  
  describe ".search" do
    before do
      Article.create(title: "Ruby Programming", content: "Ruby is a great language")
      Article.create(title: "Python Basics", content: "Python is easy to learn")
      Article.create(title: "JavaScript", content: "JavaScript is used for web development")
    end
    
    it "returns articles matching the query in title" do
      results = Article.search("Ruby")
      expect(results.count).to eq(1)
      expect(results.first.title).to eq("Ruby Programming")
    end
    
    it "returns articles matching the query in content" do
      results = Article.search("great")
      expect(results.count).to eq(1)
      expect(results.first.title).to eq("Ruby Programming")
    end
    
    it "returns multiple articles when query matches multiple" do
      results = Article.search("is")
      expect(results.count).to eq(3)
    end
    
    it "returns empty when no matches" do
      results = Article.search("Golang")
      expect(results.count).to eq(0)
    end
  end
end
