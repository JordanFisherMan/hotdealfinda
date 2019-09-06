class Category < ApplicationRecord
  validates :slug, presence: true, uniqueness: true
  has_many :deals
end
