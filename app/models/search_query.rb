class SearchQuery < ApplicationRecord
    validates :query, presence: true
    validates :ip_address, presence: true
    
    before_save :set_query_length
    before_save :update_last_searched_at
    
    def self.track_search(query, ip_address)
      return if query.blank?
      
      search_query = find_or_initialize_by(query: query, ip_address: ip_address)
      
      if search_query.new_record?
        search_query.search_count = 1
      else
        search_query.search_count = search_query.search_count.to_i + 1
      end

      search_query.save!
      search_query
    end
    
    def self.analytics_for_ip(ip_address)
      where(ip_address: ip_address)
        .order(search_count: :desc)
        .limit(10)
    end
    
    def self.top_searches(limit = 10)
      group(:query)
        .order(Arel.sql('SUM(search_count) DESC'))
        .limit(limit)
        .sum(:search_count)
    end
    
    def self.searches_by_ip(ip_address)
      where(ip_address: ip_address)
        .group(:query)
        .sum(:search_count)
    end

    private

    def set_query_length
      self.query_length = query.length
    end

    def update_last_searched_at
      self.last_searched_at = Time.current
    end
  end