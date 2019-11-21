require 'rails_helper'

RSpec.describe EbookSignup, type: :model do
  describe 'basic validations' do
    subject { build(:ebook_signup) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to allow_value("email@addresse.foo").for(:email) }
    it { is_expected.to_not allow_value("foo").for(:email) }
  end
end
