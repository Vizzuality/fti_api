# == Schema Information
#
# Table name: observations
#
#  id                    :integer          not null, primary key
#  severity_id           :integer
#  observation_type      :integer          not null
#  user_id               :integer
#  publication_date      :datetime
#  country_id            :integer
#  operator_id           :integer
#  government_id         :integer
#  pv                    :string
#  is_active             :boolean          default(TRUE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  lat                   :decimal(, )
#  lng                   :decimal(, )
#  fmu_id                :integer
#  subcategory_id        :integer
#  validation_status     :integer          default("Created"), not null
#  observation_report_id :integer
#  actions_taken         :text
#  modified_user_id      :integer
#  law_id                :integer
#  location_information  :string
#  is_physical_place     :boolean          default(TRUE)
#

FactoryBot.define do
  factory :observation_1, class: 'Observation' do
    severity
    country
    species { build_list(:species, 1) }
    user { build(:admin) }
    operator { build(:operator, name: "Operator #{Faker::Lorem.sentence}") }
    observation_type { 'operator' }
    is_active { true }
    evidence { 'Operator observation' }
    publication_date { DateTime.now.to_date }
    lng { 12.2222 }
    lat { 12.3333 }
  end

  factory :observation_2, class: 'Observation' do
    severity
    government
    country
    species { build_list(:species, 1, name: "Species #{Faker::Lorem.sentence}") }
    user { build(:admin) }
    observation_type { 'government' }
    is_active { true }
    evidence { 'Governance observation' }
    publication_date { DateTime.now.yesterday.to_date }
    lng { 12.2222 }
    lat { 12.3333 }
  end

  factory :observation, class: 'Observation' do
    country
    subcategory
    user { build(:admin) }
    severity { build(:severity, subcategory: subcategory) }
    operator { build(:operator, country: country) }
    government { build(:government, country: country) }
    observation_type { %w[operator government].sample }
    observers { build_list(:observer, 1) }
    species { build_list(:species, 1, name: "Species #{Faker::Lorem.sentence}") }
    is_active { true }
    validation_status { 'Approved' }
    evidence { 'Operator observation' }
    publication_date { DateTime.now.to_date }
    lng { 12.2222 }
    lat { 12.3333 }

    after(:build) do |observation|
      observation.observers.each { |observer| observer.translation.name = observer.name  }
    end
  end
end
