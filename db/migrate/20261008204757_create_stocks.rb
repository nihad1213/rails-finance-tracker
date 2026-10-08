class CreateStocks < ActiveRecord::Migration[8.1]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.string :name
      t.string :exchange
      t.date :last_price_date
      t.datetime :last_fetched_at
      t.decimal :last_price, precision: 12, scale: 4
      t.timestamps
    end
    add_index :stocks, :symbol, unique: true
  end
end
