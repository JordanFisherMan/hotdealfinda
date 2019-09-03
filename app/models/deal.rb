class Deal < ApplicationRecord
  validates :deal_id, :image_url, :title, :price, :url, :expiry_date,
            :channel, :division, :rating, :sort_price, :country_code, presence: true
  validates :deal_id, uniqueness: true
end
