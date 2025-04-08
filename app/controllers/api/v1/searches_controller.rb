module Api
  module V1
    class SearchesController < ApplicationController
      skip_before_action :verify_authenticity_token
      
      def search
        render json: { status: 'success' }
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
  end
end
  