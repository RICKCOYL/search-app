class SearchQuery < ApplicationRecord
    validates :query, presence: true
    validates :ip_address, presence: true
    
    # Get top searches
    def self.top_searches(limit = 10)
      where(completed: true)
        .group(:query)
        .order('count_id DESC')
        .limit(limit)
        .count(:id)
    end
    
    def self.searches_by_ip(ip_address)
      where(ip_address: ip_address, completed: true)
        .group(:query)
        .order('count_id DESC')
        .count(:id)
    end
    
    def self.mark_previous_as_incomplete(ip_address)
      where(ip_address: ip_address, completed: true)
        .update_all(completed: false)
    end
    
    def self.find_and_mark_completed(query, ip_address)
      potential_prefixes = where(ip_address: ip_address)
        .where("query LIKE ?", "#{query}%")
        .order(created_at: :desc)
        .limit(10)
      
      create(query: query, ip_address: ip_address, completed: true)
    end
  end