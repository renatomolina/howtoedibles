require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'basic validations' do
    subject { build(:message) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:body) }
  end
end
