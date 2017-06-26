class Recipe < ApplicationRecord
  is_impressionable counter_cache: true
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\z/
  has_attached_file :photo, :default_url => "/images/missing.png"

  belongs_to :category

  private

  def should_generate_new_friendly_id?
    name_changed? || super
  end

  def suggestion_portion_default
    self.suggestion_portion || '20'
  end

  def suggestion_weed_default
    self.suggestion_portion || '3'
  end
end
