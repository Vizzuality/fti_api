class MigrateGlobalizeTranslations < ActiveRecord::Migration[5.0]
  MIGRATED_DATA = {
    categories: { singular: :category, columns: %i[name] },
    contributors: { singular: :contributor, columns: %i[name description] },
    countries: { singular: :country, columns: %i[name region_name] },
    faqs: { singular: :faq, columns: %i[question answer] },
    fmus: { singular: :fmu, columns: %i[name] },
    governments: { singular: :government, columns: %i[government_entity details] },
    how_tos: { singular: :how_to, columns: %i[name description] },
    observations: { singular: :observation, columns: %i[details concern_opinion litigation_status] },
    observers: { singular: :observer, columns: %i[name organization] },
    operators: { singular: :operator, columns: %i[name details] },
    required_gov_document_groups: { singular: :required_gov_document_group, columns: %i[name] },
    required_gov_documents: { singular: :required_gov_document, columns: %i[explanation] },
    required_operator_document_groups: { singular: :required_operator_document_group, columns: %i[name] },
    required_operator_documents: { singular: :required_operator_document, columns: %i[explanation] },
    severities: { singular: :severity, columns: %i[details] },
    species: { singular: :species, columns: %i[common_name] },
    subcategories: { singular: :subcategory, columns: %i[name details] },
    tools: { singular: :tool, columns: %i[name description] },
    tutorials: { singular: :tutorial, columns: %i[name description] }
  }.freeze

  def up
    MIGRATED_DATA.each do |table, data|
      change_table(table) do |t|
        data[:columns].each do |column|
          t.jsonb column, default: {}
        end
      end
    end

    MIGRATED_DATA.each do |table, data|
      execute(build_query(table, data))
    end
  end

  def down
    MIGRATED_DATA.each do |table, data|
      change_table(table) do |t|
        data[:columns].each { |column| t.remove column }
      end
    end
  end

  private

  def build_query(table, singular:, columns:)
    columns_query = columns.map do |column|
      "#{column} = (SELECT jsonb_object_agg(locale, #{column}) FROM #{singular}_translations WHERE #{singular}_id = #{table}.id)"
    end

    "UPDATE #{table} SET #{columns_query.join(', ')}"
  end
end
