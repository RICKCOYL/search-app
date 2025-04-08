class AddSearchCountToSearchQueries < ActiveRecord::Migration[7.1]
  def change
    add_column :search_queries, :search_count, :integer, default: 1, null: false
  end
end 