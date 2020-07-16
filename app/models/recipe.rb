class Recipe < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  DEFAULT_POTENCY = 14
  DEFAULT_QUANTITY = 3.5
  DEFAULT_PORTION = 50

  belongs_to :category

  has_attached_file :photo, s3_protocol: :https
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\z/
  validates :name, :description, :ingredients, :instructions, presence: true

  scope :published, -> { where(published: true) }
end
