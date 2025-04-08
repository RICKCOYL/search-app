class AddQueryLengthToSearchQueries < ActiveRecord::Migration[7.1]
  def change
    add_column :search_queries, :query_length, :integer
  end
end 