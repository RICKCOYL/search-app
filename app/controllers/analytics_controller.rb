class AnalyticsController < ApplicationController
  def index
    @top_searches = SearchQuery.top_searches(10) || {}
    @user_searches = SearchQuery.searches_by_ip(request.remote_ip) || {}
    
    respond_to do |format|
      format.html
      format.json { 
        render json: {
          top_searches: @top_searches,
          user_searches: @user_searches
        }
      }
    end
  end
end