class EbookSignup < ApplicationRecord
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false, message: :unique },
                    format: { with: /\A[^@\s]+@([^@\s]+\.)+[^@\s]+\z/ }
end
