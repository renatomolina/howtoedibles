require 'rails_helper'
require "validates_email_format_of/rspec_matcher"

RSpec.describe ContactMessage, type: :model do
  describe 'basic validations' do
    subject { build(:contact_message) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:body) }
    it { should validate_email_format_of(:email).with_message('Please enter a valid email address.') }
  end
end
