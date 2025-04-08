class AddUniqueIndexToSearchQueries < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      DELETE FROM search_queries a
      USING search_queries b
      WHERE a.id > b.id
      AND a.query = b.query
      AND a.ip_address = b.ip_address;
    SQL

    add_index :search_queries, [:query, :ip_address], unique: true
  end

  def down
    remove_index :search_queries, [:query, :ip_address]
  end
end 