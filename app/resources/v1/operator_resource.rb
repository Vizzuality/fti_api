module V1
  class OperatorResource < JSONAPI::Resource
    caching
    attributes :name, :operator_type, :concession, :is_active, :logo, :details,
               :percentage_valid_documents_fmu, :percentage_valid_documents_country,
               :percentage_valid_documents_all, :certification, :score, :obs_per_visit,
               :website, :address, :fa_id

    has_one :country
    has_many :fmus
    has_many :users
    has_many :observations

    has_many :operator_documents
    has_many :operator_document_fmus
    has_many :operator_document_countries

    filters :country, :is_active, :name, :operator_type, :fa_operator

    before_create :set_active

    def set_active
      user = context[:current_user]
      @model.is_active = false unless user.present?
    end


    def self.updatable_fields(context)
      super - [:score, :obs_per_visit, :fa_id,
               :percentage_valid_documents_fmu, :percentage_valid_documents_country, :percentage_valid_documents_all]
    end

    def self.creatable_fields(context)
      super - [:score, :obs_per_visit, :fa_id,
               :percentage_valid_documents_fmu, :percentage_valid_documents_country, :percentage_valid_documents_all]
    end

    def self.sortable_fields(context)
      super + [:'country.name']
    end

    filter :'country.name', apply: ->(records, value, _options) {
      if value.present?
        sanitized_value = ActiveRecord::Base.connection.quote("%#{value[0].downcase}%")
        records.joins(:country).joins([country: :translations]).where("lower(country_translations.name) like #{sanitized_value}")
      else
        records
      end
    }

    filter :fa_operator, apply: ->(records, value, _options) {

    }

    def self.records(options = {})
      context = options[:context]
      user = context[:current_user]
      app = context[:app]
      if app == 'observations-tool' && user.present?
        Operator
      else
        Operator.active.fa_operator
      end
    end

    def custom_links(_)
      { self: nil }
    end
  end
end
