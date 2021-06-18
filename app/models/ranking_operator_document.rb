# frozen_string_literal: true

class RankingOperatorDocument
  include ActiveModel::Model

  attr_accessor :operator_id, :country_id, :position, :total

  class << self
    def for_operator(operator)
      return if operator.blank?

      calculated_ranking
        .select { |ranking| ranking['operator_id'] == operator.id }
        .map { |ranking| RankingOperatorDocument.new(ranking) }
        .first
    end

    def all
      calculated_ranking.map { |ranking| RankingOperatorDocument.new(ranking) }
    end

    def reload
      Rails.cache.delete(cache_key)
    end

    private

    def calculated_ranking
      # Rules: COPIED OVER from old service
      # Operators must have FA_ID
      # Operators that have 0 documents should all be last with the ranking equal to the number of operators
      query =
      <<~SQL
        SELECT
          o.id as operator_id,
          o.country_id,
          CASE
          WHEN "all" = 0 THEN
            COUNT(*) OVER (PARTITION BY o.country_id)
          ELSE
            RANK() OVER (PARTITION BY o.country_id ORDER BY "all" DESC)
          END as position,
          COUNT(*) OVER (PARTITION BY o.country_id) as total
        FROM score_operator_documents sod
          INNER JOIN operators o on o.id = sod.operator_id
            AND o.fa_id <> ''
            AND o.is_active = true
            AND sod.current = true
          INNER JOIN countries c on c.id = o.country_id AND c.is_active = true
      SQL

      Rails.cache.fetch(cache_key, expires_in: 12.hours) do
        ActiveRecord::Base.connection.execute(query).to_a
      end
    end

    def cache_key
      documents_last_change = OperatorDocument.order(updated_at: :desc).select(:updated_at).first&.updated_at
      "ranking_operator_document_cache_#{documents_last_change}"
    end
  end
end
