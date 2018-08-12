class Recipe < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  belongs_to :category

  validates :name, :description, :ingredients, :instructions, presence: true

  has_attached_file :photo, s3_protocol: :https
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\z/
end
