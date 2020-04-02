class AddNewFieldToDeals < ActiveRecord::Migration[5.2]
  def change
    add_column :deals, :new, :boolean
  end
end
