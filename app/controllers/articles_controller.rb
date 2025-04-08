class ArticlesController < ApplicationController
  def index
    @articles = Article.all.limit(20)
  end
end