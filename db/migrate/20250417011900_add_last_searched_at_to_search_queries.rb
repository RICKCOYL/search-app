class AddLastSearchedAtToSearchQueries < ActiveRecord::Migration[7.1]
  def change
    add_column :search_queries, :last_searched_at, :datetime
  end
end 