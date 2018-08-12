class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  validates :name, presence: true

  has_many :recipes
end
