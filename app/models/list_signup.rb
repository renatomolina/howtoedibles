class ListSignup
  include ActiveModel::Validations

  validates :email, presence: true
  validates_format_of :email, :with => /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/

  attr_reader :email

  def initialize(email:)
    @email = email
  end
end