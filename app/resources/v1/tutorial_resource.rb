module V1
  class TutorialResource < JSONAPI::Resource
    include CachableByLocale
    immutable
    caching

    attributes :position, :name, :description

    def self.default_sort
      [{field: :position, direction: :asc}]
    end

    def custom_links(_)
      { self: nil }
    end
  end
end
