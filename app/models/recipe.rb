class Recipe < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  has_attached_file :photo, s3_protocol: :https
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\z/

  belongs_to :category
end
