module Search
  class SearchController < ApplicationController
    def index
      @top_searches = SearchQuery.top_searches
      @user_searches = current_ip_searches
      render template: 'search/index'
    end

    def search
      query = params[:query].to_s.strip
      ip_address = get_client_ip
      
      search_query = SearchQuery.track_search(query, ip_address)

      render json: { 
        status: 'success',
        top_searches: SearchQuery.top_searches,
        user_searches: current_ip_searches.map { |s| { query: s.query, search_count: s.search_count } }
      }
    end

    private

    def current_ip_searches
      SearchQuery.analytics_for_ip(get_client_ip)
    end

    def get_client_ip
      return request.remote_ip if Rails.env.development?

      forwarded_ip = request.env['HTTP_X_FORWARDED_FOR']&.split(',')&.first
      real_ip = request.env['HTTP_X_REAL_IP']
      remote_addr = request.env['REMOTE_ADDR']
      
      ip = forwarded_ip || real_ip || remote_addr || request.remote_ip || request.ip
      ip.presence || '127.0.0.1'
    end
  end
end 