module V1
  class ObservationResource < JSONAPI::Resource
    caching

    attributes :observation_type, :publication_date,
               :pv, :is_active, :details, :evidence, :concern_opinion,
               :litigation_status, :lat, :lng,
               :country_id, :fmu_id,
               :subcategory_id, :severity_id, :created_at, :updated_at, :actions_taken

    has_many :species
    has_many :comments
    has_many :photos
    has_many :observation_documents
    has_many :observers

    has_one :country
    has_one :subcategory
    has_one :severity
    has_one :user
    has_one :operator
    has_one :government

    before_create :add_own_observer

    filters :id, :observation_type, :fmu_id, :country_id, :fmu_id,
            :publication_date, :observer_id, :subcategory_id, :years

    filter :category_id, apply: ->(records, value, _options) {
      records.joins(:subcategory).where('subcategories.category_id = ?', value[0].to_i)
    }

    filter :severity_level, apply: ->(records, value, _options) {
      records.joins(:subcategory).where('subcategories.category_id = ?', value[0].to_i)
    }

    filter :years, apply: ->(records, value, _options) {
      records.where("extract(year from observations.publication_date) in (#{value.map{|x| x.to_i rescue nil}.join(', ')})")
    }

    filter :'observation_report.id', apply: ->(records, value, _options) {
      records.joins(:observation_report).where('observation_reports.id = ?', value[0].to_i)
    }

    def self.sortable_fields(context)
      super + [:'country.iso', :'severity.level', :'subcategory.name', :'operator.name']
    end

    def custom_links(_)
      { self: nil }
    end

    def add_own_observer
      begin
        user = context[:current_user]
        @model.observers << Observer.find(user.observer_id) if user.observer_id.present?
      rescue Exception => e
        Rails.logger.warn "Observation created without user: #{e.inspect}"
      end
    end

    # To allow the filtering of results according to the app and user
    # In the portal, only the approved observations should be shown
    # (using the default scope)
    # In the observation tools, the monitors should see theirs

    def self.records(options = {})
      context = options[:context]
      user = context[:current_user]
      app = context[:app]
      if app == 'observations-tool' && user.present?
        if user.observer_id.present?
          Observation.own_with_inactive(user.observer_id)
        elsif user.user_permission.present? && user.user_permission.user_role == 'admin'
          Observation
        else
          Observation.active
        end
      else
        Observation.active
      end
    end

  end
end
