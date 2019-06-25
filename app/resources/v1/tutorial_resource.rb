module V1
  class TutorialResource < JSONAPI::Resource
    immutable
    caching

    attributes :position, :name, :description

    def self.default_sort
      [{field: :position, direction: :asc}]
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