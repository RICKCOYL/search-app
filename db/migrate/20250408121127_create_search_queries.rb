class CreateSearchQueries < ActiveRecord::Migration[7.1]
  def change
    create_table :search_queries do |t|
      t.string :query, null: false
      t.string :ip_address, null: false
      t.boolean :completed, default: false
      t.integer :query_length
      t.integer :search_count, default: 1
      t.datetime :last_searched_at
      t.timestamps
    end

    add_index :search_queries, [:ip_address, :completed]
    add_index :search_queries, [:query, :ip_address], unique: true
    add_index :search_queries, :last_searched_at
  end
end
