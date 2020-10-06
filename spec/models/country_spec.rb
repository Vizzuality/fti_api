# == Schema Information
#
# Table name: countries
#
#  id                         :integer          not null, primary key
#  iso                        :string
#  region_iso                 :string
#  country_centroid           :jsonb
#  region_centroid            :jsonb
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  is_active                  :boolean          default("false"), not null
#  percentage_valid_documents :float
#  name                       :string
#  region_name                :string
#

require 'rails_helper'

RSpec.describe Country, type: :model do
  subject(:country) { FactoryBot.build(:country) }

  it 'is valid with valid attributes' do
    country = build(:country)
    expect(country).to be_valid
  end

  it_should_behave_like 'translatable', FactoryBot.create(:country), %i[name region_name]

  context 'Hooks' do
    describe '#set_active' do
      context 'when is_active has not been initialized' do
        it 'set is_active to true' do
          country = create(:country, is_active: nil)
          expect(country.is_active).to eql true
        end
      end

      context 'when is_active has been initialized' do
        it 'keep the value of is_active' do
          country = Country.create(is_active: false)
          expect(country.is_active).to eql false
        end
      end
    end
  end

  context 'Methods' do
    describe '#cache_key' do
      it 'return the default value with the locale' do
        country = create(:country)
        expect(country.cache_key).to match(/-#{Globalize.locale.to_s}\z/)
      end
    end
  end
end
