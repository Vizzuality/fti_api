# frozen_string_literal: true
# == Schema Information
#
# Table name: fmus
#
#  id          :integer          not null, primary key
#  country_id  :integer
#  operator_id :integer
#  geojson     :jsonb
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Fmu < ApplicationRecord
  include ValidationHelper
  translates :name

  belongs_to :country, inverse_of: :fmus
  belongs_to :operator, inverse_of: :fmus
  has_many :documents, as: :attacheable, dependent: :destroy
  has_many :observations, inverse_of: :fmu

  accepts_nested_attributes_for :documents, allow_destroy: true

  validates :country_id, presence: true

  default_scope { includes(:translations) }

  scope :filter_by_countries,  ->(country_ids)  { where(country_id: country_ids.split(',')) }
  scope :filter_by_operators,  ->(operator_ids) { where(operator_id: operator_ids.split(',')) }

  class << self
    def fetch_all(options)
      country_ids  = options['country_ids'] if options.present? && options['country_ids'].present? && ValidationHelper.ids?(options['country_ids'])
      operator_ids  = options['operator_ids'] if options.present? && options['operator_ids'].present? && ValidationHelper.ids?(options['operator_ids'])

      fmus = includes([:country, :operator])
      fmus = fmus.filter_by_countries(country_ids) if country_ids.present?
      fmus = fmus.filter_by_operators(operator_ids) if operator_ids.present?
      fmus
    end
  end

  def cache_key
    super + '-' + Globalize.locale.to_s
  end
end
