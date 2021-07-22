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
#  pv                    :string
#  is_active             :boolean          default("true")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  lat                   :decimal(, )
#  lng                   :decimal(, )
#  fmu_id                :integer
#  subcategory_id        :integer
#  validation_status     :integer          default("0"), not null
#  observation_report_id :integer
#  actions_taken         :text
#  modified_user_id      :integer
#  law_id                :integer
#  location_information  :string
#  is_physical_place     :boolean          default("true")
#  evidence_type         :integer
#  location_accuracy     :integer
#  evidence_on_report    :string
#  hidden                :boolean          default("false")
#  admin_comment         :text
#  monitor_comment       :text
#  responsible_admin_id  :integer
#  deleted_at            :datetime
#  details               :text
#  concern_opinion       :text
#  litigation_status     :string
#  deleted_at            :datetime
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
    evidence_type { 'Photos' }
    publication_date { DateTime.now.to_date }
    location_accuracy { 'Estimated location' }
    lng { 12.2222 }
    lat { 12.3333 }
  end

  factory :observation_2, class: 'Observation' do
    severity
    country
    governments { build_list(:government, 2) }
    species { build_list(:species, 1, name: "Species #{Faker::Lorem.sentence}") }
    user { build(:admin) }
    observation_type { 'government' }
    is_active { true }
    publication_date { DateTime.now.yesterday.to_date }
    lng { 12.2222 }
    lat { 12.3333 }
  end

  factory :observation, class: 'Observation' do
    country
    subcategory
    observation_report
    user { build(:admin) }
    severity { build(:severity, subcategory: subcategory) }
    operator { create(:operator, country: country) }
    observation_type { 'operator' }
    observers { build_list(:observer, 1) }
    species { build_list(:species, 1, name: "Species #{Faker::Lorem.sentence}") }
    is_active { true }
    validation_status { 'Published (no comments)' }
    publication_date { DateTime.now.to_date }
    lng { 12.2222 }
    lat { 12.3333 }

    factory :created_observation, class: 'Observation' do
      validation_status { 'Created' }
    end

    after(:build) do |observation|
      observation.observers.each { |observer| observer.translation.name = observer.name  }
    end
  end
end
