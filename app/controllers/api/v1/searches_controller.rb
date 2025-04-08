class Api::V1::SearchesController < ApplicationController
    skip_before_action :verify_authenticity_token
    
    def search
      @articles = Article.search(params[:query])
      render json: @articles
    end
    
    def record
      ip_address = request.remote_ip
      query = params[:query].strip
      
      if query.present?
        SearchQuery.find_and_mark_completed(query, ip_address)
        render json: { status: 'success' }
      else
        render json: { status: 'error', message: 'Empty query' }
      end
    end
  end
  