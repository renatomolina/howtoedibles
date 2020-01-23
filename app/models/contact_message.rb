class ContactMessage
  include ActiveModel::Model
  attr_accessor :name, :email, :body
  validates :name, :email, :body, presence: true
  validates_email_format_of :email, :message => 'Please enter a valid email address.'
end
