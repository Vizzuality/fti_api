# frozen_string_literal: true

module FileDataImport
  class BelongsToAssociation
    include FileDataImport::Concerns::HasAttributes

    attr_accessor(
      :class_name, :permitted_attributes, :permitted_translations,
      :raw_attributes, :abilities, :errors, :required, :belongs_as, :use_shared_belongs_to
    )

    def initialize(class_name, raw_attributes, **options)
      @class_name = class_name
      @permitted_attributes = options[:permitted_attributes]&.map(&:to_sym) || []
      @permitted_translations = options[:permitted_translations]&.map(&:to_sym) || []
      @raw_attributes = raw_attributes.transform_values(&:presence)
      @abilities = options[:can]&.map(&:to_sym) || []
      @required = options[:required]
      @belongs_as = options[:as]
      @use_shared_belongs_to = options[:use_shared_belongs_to] || []
      @errors = {}
    end

    def singular_name
      @singular_name ||= belongs_as || class_name.model_name.singular.to_sym
    end

    def attributes
      attributes_for_finding
    end

    def record
      @record ||= begin
        record = class_name.find_by(attributes_for_finding) if attributes_for_finding.present?

        if record.present?
          record
        elsif abilities.include?(:create)
          class_name.new(attributes_for_creation)
        end
      end
    end

    def save
      if record.blank?
        errors[:presence] = "record is absent" if required
        return
      end

      errors.merge!(record.errors.messages) unless record.save
    end

    private

    def extracted_attributes
      @extracted_attributes ||= extract_attributes(permitted_attributes)
    end

    def translations_attributes
      @translations_attributes ||= extract_attributes(permitted_translations)
    end

    def extract_attributes(attrs)
      attrs.each_with_object({}) do |attribute, attributes|
        value = raw_attributes["#{singular_name}__#{attribute}".to_sym]
        attributes[attribute] = value if value.present?
      end
    end
  end
end
