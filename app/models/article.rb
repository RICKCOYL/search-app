class Article < ApplicationRecord
    validates :title, presence: true
    
    def self.search(query)
      where("title ILIKE ? OR content ILIKE ?", "%#{query}%", "%#{query}%") if query.present?
    end
  end