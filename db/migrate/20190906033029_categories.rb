class Categories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :slug, null: false
    end
    add_index :categories, :slug, unique: true
  end
end
