class Recipe < ApplicationRecord
  is_impressionable
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  has_attached_file :photo
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\z/

  belongs_to :category

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end
end
