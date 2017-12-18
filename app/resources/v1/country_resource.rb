# frozen_string_literal: true

module V1
  class CountryResource < JSONAPI::Resource
    caching

    attributes :iso, :region_iso, :country_centroid,
               :region_centroid, :is_active, :region_name, :name

    has_many :fmus
    has_many :required_operator_documents
    has_many :governments
    has_many :monitors

    filter :iso
    filter :is_active, default: 'true',
                       apply: ->(records, value, _options) {
             if %w(true false).include?(value.first)
               records.where(is_active: value.first)
             else
               records
             end
           }

    # Hack to ignore the sort by name for now
    def self.apply_sort(records, order_options, context = {})
      order_options.except! 'name' if order_options.key?('name')
      super(records, order_options, context)
    end

    def custom_links(_)
      { self: nil }
    end

    # Adds the locale to the cache
    def self.attribute_caching_context(context)
      {
          locale: context[:locale]
      }
    end
  end
end
