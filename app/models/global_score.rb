# frozen_string_literal: true

# == Schema Information
#
# Table name: global_scores
#
#  id               :integer          not null, primary key
#  date             :datetime         not null
#  total_required   :integer
#  general_status   :jsonb
#  country_status   :jsonb
#  fmu_status       :jsonb
#  doc_group_status :jsonb
#  fmu_type_status  :jsonb
#  country_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class GlobalScore < ApplicationRecord
  belongs_to :country, optional: true
  validates_presence_of :date
  validates_uniqueness_of :date, scope: :country_id

  def self.headers
    @headers ||= initialize_headers
  end

  # Calculates the score for a given day
  # @param [Country] country The country for which to calculate the global score (if nil, will calculate all)
  def self.calculate(country = nil)
    GlobalScore.transaction do
      gs = GlobalScore.find_or_create_by(country: country, date: Date.current)
      all = country.present? ? OperatorDocument.by_country(country&.id) : OperatorDocument.all
      gs.total_required = all.count
      gs.general_status = all.group(:status).count
      gs.country_status = all.country_type.group(:status).count
      gs.fmu_status     = all.fmu_type.group(:status).count
      gs.doc_group_status = all.joins(required_operator_document: :required_operator_document_group)
                                .group('required_operator_document_groups.id').count
      gs.fmu_type_status = all.fmu_type.joins(:fmu).group('fmus.forest_type').count
      gs.save!
    end
  end

  def self.to_csv
    CSV.generate(headers: true, force_quotes: true) do |csv|
      csv << headers.map{ |x| x.is_a?(Hash) ? x.values.first.map{ |y| "#{x.keys.first}-#{y[0]}" }  : x }.flatten

      find_each do |score|
        tmp_row = []
        headers.each do |h|
          if h.is_a?(Hash)
            h.values.first.each { |k| tmp_row << score[h.keys.first][k.last.to_s] }
          else
            tmp_row << score[h]
          end
        end
        csv << tmp_row
      end
    end
  end


  private

  def self.initialize_headers
    rodg_name = Arel.sql("required_operator_document_group_translations.name")
    statuses = {}
    OperatorDocument.statuses.each_key { |v| statuses[v] = v }
    [
      :date,
      :country,
      :total_required,
      { general_status: statuses },
      { country_status: statuses },
      { fmu_status: statuses },
      { doc_group_status: RequiredOperatorDocumentGroup.with_translations(I18n.locale)
                              .pluck(:id, rodg_name).map{ |x| { x[1] => x[0] } }.inject({}, :merge) },
      { fmu_type_status: Fmu.forest_types }
    ]
  end
end
