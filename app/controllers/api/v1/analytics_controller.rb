class Api::V1::AnalyticsController < ApplicationController
  skip_before_action :verify_authenticity_token
  def index
    top_searches = SearchQuery.top_searches || {}
    user_searches = SearchQuery.searches_by_ip(request.remote_ip) || {}
    
    render json: {
      top_searches: top_searches,
      user_searches: user_searches
    }
  end
end