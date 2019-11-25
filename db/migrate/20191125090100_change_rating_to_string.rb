class ChangeRatingToString < ActiveRecord::Migration[5.2]
  def change
    change_column :deals, :rating, :string
  end
end
