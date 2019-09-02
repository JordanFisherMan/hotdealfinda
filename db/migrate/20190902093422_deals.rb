class Deals < ActiveRecord::Migration[5.2]
  def change
    create_table :deals do |t|
      t.string :deal_id, null: false
      t.string :image_url, null: false
      t.text :title, null: false
      t.text :highlights
      t.string :price, null: false
      t.text :url, null: false
      t.date :expiry_date, null: false
      t.string :category
      t.string :channel, null: false
      t.string :division, null: false
      t.integer :rating, null: false
      t.float :sort_price, null: false
      t.string :country_code, null: false
      t.timestamps null: false
    end
    add_index :deals, :deal_id, unique: true
  end
end
