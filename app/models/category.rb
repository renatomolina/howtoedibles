class Category < ApplicationRecord
  extend FriendlyId
  
  has_many :recipes

  friendly_id :name, use: [:slugged, :history]
end
