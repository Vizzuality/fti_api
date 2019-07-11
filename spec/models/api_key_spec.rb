require 'rails_helper'

RSpec.describe APIKey, type: :model do
  subject(:api_key) { FactoryBot.build :api_key }

  it 'is valid with valid attributes' do
    expect(api_key).to be_valid
  end

  context 'Relations' do
    it { is_expected.to belong_to(:user) }
  end

  context 'Methods' do
    context '#expired?' do
      context 'when APIKey expires_at date is lower than current date' do
        it 'returns true' do
          api_key = FactoryBot.create(:api_key, expires_at: Date.yesterday)
          expect(api_key.expired?).to eql true
        end
      end

      context 'when user is deactivated' do
        it 'returns true' do
          user = FactoryBot.create(:admin)
          user.deactivate
          api_key = FactoryBot.build(:api_key, user: user, expires_at: Date.yesterday)
          expect(api_key.expired?).to eql true
        end
      end

      context 'when APIKey is deactivated' do
        it 'returns true' do
          api_key = FactoryBot.create(:api_key)
          api_key.deactivate
          expect(api_key.expired?).to eql true
        end
      end

      context 'when APIKey has not expired' do
        it 'returns false' do
          api_key = FactoryBot.create(:api_key)
          expect(api_key.expired?).to eql false
        end
      end
    end
  end

  it_should_behave_like 'activable', :api_key, FactoryBot.build(:api_key)
end
