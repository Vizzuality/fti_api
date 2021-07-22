# frozen_string_literal: true

module FileDataImport
  class Record
    include FileDataImport::Concerns::HasAttributes

    attr_reader :class_name, :permitted_attributes, :permitted_translations, :raw_attributes, :results, :abilities

    def initialize(class_name, raw_attributes, **options)
      @class_name = class_name
      @raw_attributes = raw_attributes.transform_values(&:presence)
      @permitted_attributes = options[:permitted_attributes] || []
      @permitted_translations = options[:permitted_translations] || []
      @abilities = options[:can]&.map(&:to_sym) || %i[create update]
      @belongs_to_associations = []
      @results = { attributes: {}, errors: {} }
    end

    def id
      @id ||= raw_attributes[:id].to_i if raw_attributes[:id]
    end

    def record
      @record ||=
        if abilities.include?(:update) && id
          class_name.find_by(id: id)
        elsif abilities.include?(:create)
          class_name.new
        end
    end

    def belongs_to(association)
      @belongs_to_associations.push(association)
    end

    def save
      unless record
        results[:errors][:record] = ["record with #{id} id is not exists"]
        return
      end

      class_name.transaction do
        belongs_to_attributes =
          @belongs_to_associations.each_with_object({}) do |belongs_to_association, attributes|
            belongs_to_association.use_shared_belongs_to.each do |attribute|
              use_belongs_to = @belongs_to_associations.find { |b| b.singular_name == attribute }
              belongs_to_association.record.send("#{attribute}=", use_belongs_to.record) if use_belongs_to.present?
            end
            belongs_to_association.save
            singular_name = belongs_to_association.singular_name

            if belongs_to_association.errors.blank?
              attributes[singular_name] = belongs_to_association.record
            else
              results[:errors][singular_name] = belongs_to_association.errors
            end

            if belongs_to_association.record_attributes.present?
              results[:attributes][singular_name] = belongs_to_association.record_attributes
            end
          end

        record.assign_attributes(attributes_for_creation.merge(belongs_to_attributes))


        record.save
        results[:errors][:record] = record.errors.messages unless record.errors.empty?
        results[:attributes][:record] = record_attributes
        raise ActiveRecord::RecordInvalid if results[:errors].any?
      end
    rescue ActiveRecord::RecordInvalid
      nil
    end
  end
end
