class Recipe < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  belongs_to :category

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
