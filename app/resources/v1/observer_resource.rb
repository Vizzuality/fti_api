module V1
  class ObserverResource < JSONAPI::Resource
    caching
    attributes :observer_type, :name, :organization, :is_active, :logo, :address,
               :information_name, :information_email, :information_phone, :data_name,
               :data_email, :data_phone, :organization_type

    has_one :country
    has_many   :users
    has_many :observations

    before_save :inactivate

    def inactivate
      @model.is_active = false
    end


    def custom_links(_)
      { self: nil }
    end

    def self.updatable_fields(context)
      super - [:is_active]
    end
    def self.creatable_fields(context)
      super - [:is_active]
    end
  end
end
