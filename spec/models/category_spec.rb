require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'basic validations' do
    subject { build(:category) }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'associations' do
    subject { build(:category) }

    it { is_expected.to have_many(:recipes) }
  end
end
