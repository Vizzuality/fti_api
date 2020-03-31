# frozen_string_literal: true

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

class Country < ApplicationRecord
  # include Translatable
  # translates :name, :region_name, touch: true
  #
  # active_admin_translates :name, :region_name do
  #   validates_presence_of :name
  # end

  has_many :users,           inverse_of: :country
  has_many :observations,    inverse_of: :country
  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :observers
  # rubocop:enable Rails/HasAndBelongsToMany
  has_many :governments,     inverse_of: :country
  has_many :operators,       inverse_of: :country
  has_many :fa_operators, ->{ fa_operator }, class_name: 'Operator'
  has_many :fmus,            inverse_of: :country
  has_many :laws,            inverse_of: :country

  has_many :species_countries
  has_many :species, through: :species_countries
  has_many :required_operator_documents
  has_many :required_gov_documents
  has_many :gov_documents, -> { actual }

  validates :name, :iso, presence: true, uniqueness: { case_sensitive: false }

  before_save :set_active

  scope :by_name_asc, (-> {
    includes(:translations).with_translations(I18n.available_locales)
                           .order('country_translations.name ASC')
  })

  scope :with_observations, (-> {
    left_outer_joins(:observations).where.not(observations: { id: nil }).uniq
  })

  scope :by_status, (->(status) { where(is_active: status) })

  scope :active, (-> { where(is_active: true) })

  default_scope do
    includes(:translations)
  end

  def cache_key
    super + '-' + Globalize.locale.to_s
  end

  def update_valid_documents_percentages
    self.percentage_valid_documents =
      gov_documents.valid.count.to_f / gov_documents.joins(:required_gov_document).required.count.to_f rescue 0
    save!
  end

  private

  def set_active
    self.is_active = true unless is_active.in? [true, false]
  end
end
