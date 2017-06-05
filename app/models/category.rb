class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
