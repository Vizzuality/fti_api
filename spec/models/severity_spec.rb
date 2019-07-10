# == Schema Information
#
# Table name: severities
#
#  id             :integer          not null, primary key
#  level          :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  subcategory_id :integer
#

require 'rails_helper'

RSpec.describe Severity, type: :model do
  subject(:severity) { FactoryGirl.build :severity }

  it_should_behave_like 'translatable', FactoryGirl.build(:severity), %i[details]

  it 'is valid with valid attributes' do
    expect(severity).to be_valid
  end

  describe 'Relations' do
    it { is_expected.to belong_to(:subcategory).inverse_of(:severities).required }
    it { is_expected.to have_many(:observations).inverse_of(:severity) }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_uniqueness_of(:level).scoped_to(:subcategory_id) }
    it { is_expected.to validate_numericality_of(:level)
      .is_greater_than_or_equal_to(0)
      .is_less_than_or_equal_to(3)
      .only_integer
    }
  end

  describe 'Instance methods' do
    describe '#level_details' do
      it 'return level with details' do
        expect(severity.level_details).to eql "#{severity.level} - #{severity.details}"
      end
    end

    describe '#cache_key' do
      it 'return the default value with the locale' do
        expect(severity.cache_key).to match(/-#{Globalize.locale.to_s}\z/)
      end
    end
  end
end
