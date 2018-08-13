require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'basic validations' do
    subject { build(:recipe) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:ingredients) }
    it { is_expected.to validate_presence_of(:instructions) }
    it { is_expected.to validate_presence_of(:description) }
  end

  describe 'associations' do
    subject { build(:recipe) }

    it { is_expected.to belong_to(:category) }
    it { is_expected.to have_attached_file(:photo) }
  end
end
