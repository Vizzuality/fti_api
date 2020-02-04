# frozen_string_literal: true

module FileDataImport
  class BelongsToAssociation
    attr_accessor :class_name, :permited_attributes, :permited_translations, :raw_attributes, :abilities, :errors

    def initialize(class_name, raw_attributes, **options)
      @class_name = class_name
      @permited_attributes = options[:permited_attributes]&.map(&:to_sym) || []
      @permited_translations = options[:permited_translations]&.map(&:to_sym) || []
      @raw_attributes = raw_attributes
      @abilities = options[:can]&.map(&:to_sym) || []
      @errors = {}
    end

    def singular_name
      class_name.model_name.singular.to_sym
    end

    def attributes
      attributes_for_finding
    end

    def record
      @record ||= begin
        record = class_name.find_by(attributes_for_finding)

        if record.present?
          record
        elsif abilities.include?(:create)
          class_name.new(attributes_for_creation)
        end
      end
    end

    def save
      unless record
        errors[:presence] = "record is absent"
        return
      end

      errors.merge!(record.errors.messages) unless record.save
    end

    private

    def attributes_for_finding
      @attributes_for_finding ||= extracted_attributes.merge(translations_attributes)
    end

    def attributes_for_creation
      @attributes_for_creation ||= begin
        extracted_attributes.merge({ translations_attributes: [translations_attributes.merge(locale: I18n.locale)] })
      end
    end

    def extracted_attributes
      @extracted_attributes ||= begin
        permited_attributes.each_with_object({}) do |attribute, attributes|
          value = raw_attributes["#{singular_name}__#{attribute}".to_sym]
          attributes[attribute] = value if value.present?
        end
      end
    end

    def translations_attributes
      @translations_attributes ||=
        permited_translations.each_with_object({}) do |attribute, attributes|
          value = raw_attributes["#{singular_name}__#{attribute}".to_sym]
          attributes[attribute] = value if value
        end
    end
  end
end
