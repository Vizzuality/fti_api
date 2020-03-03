# frozen_string_literal: true

module V1
  class SubcategoryResource < JSONAPI::Resource
    include CacheableByLocale
    caching

    attributes :name, :details, :subcategory_type, :category_id, :location_required

    has_one :category
    has_many :severities
    has_many :country_subcategories
    has_many :observations

    filters :id, :name, :subcategory_type, :category_id

    filter :observation_type, apply: ->(records, value, _options) {
      records.joins(:observations).where('observations.observation_type = ?', value[0].to_i)
    }

    def self.sortable_fields(context)
      super + [:'category.name']
    end

    def custom_links(_)
      { self: nil }
    end
  end
end
