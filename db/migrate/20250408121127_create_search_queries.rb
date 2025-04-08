class CreateSearchQueries < ActiveRecord::Migration[7.1]
  def change
    create_table :search_queries do |t|
      t.string :query
      t.string :ip_address
      t.boolean :completed

      t.timestamps
    end
  end
end
